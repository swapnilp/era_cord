class JkciClassesController < ApplicationController
  before_action :authenticate_user!, except: [:sync_organisation_classes, :sync_organisation_class_students]

  
  before_action :active_standards!, only: [:index]
  #skip_before_filter :authenticate_with_token!, only: [:sub_organisation_class_report]
  load_and_authorize_resource param_method: :my_sanitizer, except: [:sync_organisation_classes, :sync_organisation_class_students]

  skip_before_filter :authenticate_with_token!, only: [:sync_organisation_classes, :sync_organisation_class_students]
  skip_before_filter :verify_authenticity_token, only: [:sync_organisation_classes, :sync_organisation_class_students]
  skip_before_filter :require_no_authentication, :only => [:sync_organisation_classes, :sync_organisation_class_students]

  before_filter :authenticate_org_with_token!, only: [:sync_organisation_classes, :sync_organisation_class_students]
  before_action :authenticate_organisation!, only: [:sync_organisation_classes, :sync_organisation_class_students]

  def index
    teacher = current_user.teacher if current_user.teacher.try(:active)
    if params[:is_teacher] && teacher.present? && !current_user.has_role?(:clerk)
      jkci_classes = teacher.jkci_classes.where(standard_id: @active_standards).active.uniq.order("id desc")
    else
      jkci_classes = @organisation.jkci_classes.where(standard_id: @active_standards).active.order("id desc")
    end
    
    #jkci_classes = @organisation.standards.where("organisation_standards.is_assigned_to_other = false").map(&:jkci_classes).map(&:last)
    render json: {success: true, body: ActiveModel::ArraySerializer.new(jkci_classes, each_serializer: JkciClassIndexSerializer).as_json, teacher_id: teacher.try(:id)}
  end

  def get_unassigned_classes
    #jkci_classes = @organisation.standards.where("organisation_standards.is_assigned_to_other = true").map(&:jkci_classes).map(&:last)
    jkci_classes = JkciClass.where("id not in (?) && is_current_active = ? && standard_id in (?)", @organisation.jkci_classes.map(&:id) << 0, true, @organisation.organisation_standards.map(&:standard_id) << 0)#@organisation.descendants.map(&:jkci_classes).map(&:active).flatten
    render json: {body: jkci_classes.map(&:unassigned_json)}
  end

  def get_exam_info
    if current_user.has_role?(:teacher)
      jkci_class = JkciClass.includes({subjects: :standard}).where(id: params[:id]).first
    else
      jkci_class = @organisation.jkci_classes.includes({subjects: :standard}).where(id: params[:id]).first
    end
    if jkci_class
      render json: {success: true, data: ClassExamDataSerializer.new(jkci_class).as_json} 
    else
      render json: {success: false}
    end
  end

  def get_dtp_info
    jkci_class = JkciClass.includes({subjects: :standard}).where(id: params[:id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    
    options = {}
    if params[:ttc_id].present?
      time_table_class = jkci_class.time_table_classes.where(id: params[:ttc_id]).first
      sub_classes = jkci_class.sub_classes.as_json({selected: [time_table_class.sub_class_id]})
      options = {subject_id: time_table_class.subject_id, sub_classes: sub_classes}
    else
      sub_classes = jkci_class.sub_classes
      options = {sub_classes: sub_classes}
    end

    if jkci_class
      render json: {success: true, data: ClassDtpDataSerializer.new(jkci_class).as_json.merge(options)} 
    else
      render json: {success: false}
    end
  end

  def show
    jkci_class = JkciClass.where(id: params[:id]).first
    #@notifications = @jkci_class.role_exam_notifications(current_user)
    if jkci_class
      render json: JkciClassSerializer.new(jkci_class).as_json.merge({success: true, has_manage_class: (current_user.has_role?(:manage_class) && jkci_class.organisation_id == @organisation.id), self_organisation: (jkci_class.organisation_id == @organisation.id || current_user.has_role?(:teacher))})
    else
      render json: {success: false}
    end
  end

  def toggle_class_sms
    jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    if jkci_class && current_user.has_role?(:manage_class_sms)
      jkci_class.update_attributes({enable_class_sms: params[:value]})
      jkci_class.create_activity key: 'jkci_class.toggle_class_sms', owner: current_user, organisation_id: @organisation.id,  parameters: params.slice("value")
      render json: {success: true, id: jkci_class.id}
    else
      render json: {success: false, message: "Some thing went wrong"}
    end
  end

  def toggle_exam_sms
    jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    if jkci_class && current_user.has_role?(:manage_class_sms)
      jkci_class.update_attributes({enable_exam_sms: params[:value]})
      jkci_class.create_activity key: 'jkci_class.toggle_exam_sms', owner: current_user, organisation_id: @organisation.id,  parameters: params.slice("value")
      render json: {success: true, id: jkci_class.id}
    else
      render json: {success: false, message: "Some thing went wrong"}
    end
  end
  
  def assign_students
    jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    selected_students = jkci_class.students.map(&:id)
    students = @organisation.students.where("id not in (?) && standard_id = ?", selected_students << 0, jkci_class.standard_id)
    render json: {success: true, students: students.map(&:assign_json)}
  end

  def manage_students
    jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    sutdents = params[:students_ids].map(&:to_i)  rescue []
    if jkci_class
      jkci_class.manage_students(sutdents, @organisation) 
      jkci_class.update_attributes({is_student_verified: false})
      jkci_class.check_duplicates(false)
      render json: {success: true, id: jkci_class.id}
    else
      render json: {success: false}
    end
  end

  def students
    jkci_class = JkciClass.where(id: params[:id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    students = jkci_class.students.includes(:standard, :batch, :jkci_classes, :removed_class_students, :student_photos).select("class_students.roll_number, students.*")
    if params[:filter].present? &&  JSON.parse(params[:filter])['name'].present?
      query = "%#{JSON.parse(params[:filter])['name']}%"
      students = students.where("CONCAT_WS(' ', first_name, last_name) LIKE ? || CONCAT_WS(' ', last_name, first_name) LIKE ? || p_mobile like ?", query, query, query)
    end
    unless params[:withoutPage]
      students = students.page(params[:page])
    end
    roles = current_user.roles.map(&:name)
    render json: {success: true, students: ActiveModel::ArraySerializer.new(students, each_serializer: StudentSerializer, scope: {image: 'thumb'}).as_json, count: students.try(:total_count), has_show_pay_info: roles.include?('accountant'), has_pay_fee: (['accountant','accountant_clerk'] & roles).size > 0}
  end

  def remove_student_from_class
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    if jkci_class
      jkci_class.remove_student_from_class(params[:student_id], @organisation) 
      jkci_class.update_attributes({is_student_verified: false})
      jkci_class.create_activity key: 'jkci_class.remove_students', owner: current_user, organisation_id: @organisation.id,  parameters: params.slice("student_id")
      jkci_class.check_duplicates(false)
      render json: {success: true, id: jkci_class.id}
    else
      render json: {success: false}
    end
  end

  def get_chapters
    jkci_class = JkciClass.where(id: params[:id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    
    chapters = jkci_class.subjects.where(id:  params[:subject_id]).first.chapters.select([:id, :name, :chapt_no])
    render json: {success: true, chapters: chapters} 
  end

  def manage_student_subject
    jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    subjects = jkci_class.subjects.optional
    students = jkci_class.class_students.includes({student: :student_subjects})
    render json: {success: true, subjects: subjects, students: students.map(&:subject_json), jkci_class: jkci_class.subject_json} 
  end

  def save_student_subjects
    jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class

    if jkci_class
      params[:students].each do |p_student|
        student = jkci_class.students.where(id: p_student['student_id']).first
        student.add_students_subjects(p_student["o_subjects"], @organisation) if student
      end
      jkci_class.create_activity key: 'jkci_class.manage_student_subject', owner: current_user, organisation_id: @organisation.id
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def manage_roll_number
    jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    if jkci_class
      jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
      students = jkci_class.class_students.joins(:student)
      render json: {success: true, students: students.map(&:roll_number_json)}
    else
      render json: {success: false}
    end
  end

  def save_roll_number
    jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    if jkci_class
      jkci_class.save_class_roll_number(params[:roll_number])
      jkci_class.create_activity key: 'jkci_class.manage_roll_number', owner: current_user, organisation_id: @organisation.id
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def get_batch
    jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    if jkci_class
      standards = @organisation.standards.where("priority > ?", jkci_class.standard.priority)
      render json: {success: true, jkci_class: jkci_class.batch_json, standards: standards.as_json}
    else
      render json: {success: false}
    end
  end

  def upgrade_batch
    jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    if jkci_class
      new_jkci_class = jkci_class.upgrade_batch(params[:student_list], @organisation, params[:standard_id])
      jkci_class.create_activity key: 'jkci_class.upgrade_batch', owner: current_user, organisation_id: @organisation.id
      render json: {success: true, class_id: new_jkci_class.id , is_same_organisation:  new_jkci_class.organisation_id == @organisation.id}
    else
      render json: {success: false}
    end
  end
  
  def get_notifications
    jkci_class = JkciClass.where(id: params[:id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    
    notifications = jkci_class.role_exam_notifications(current_user).order("id desc").page(params[:page])
    render json: {success: true, notifications: notifications, count: notifications.total_count}
  end

  def sub_organisation_class_report
    @sub_organisation = @organisation.root.subtree.where(id: params[:sub_organisation_id]).first
    @jkci_class = @sub_organisation.jkci_classes.where(id: params[:jkci_class_id]).first
    @exams_table_format = @jkci_class.exams_table_format
    @daily_teaching_table_format = @jkci_class.daily_teaching_table_format
    respond_to do |format|
      format.pdf { render :layout => false }
    end
  end

  def sub_class_students_report
    @jkci_class = JkciClass.includes([:students, {sub_classes: :jkci_class}]).where(id: params[:id]).first
    @students = @jkci_class.class_students.map{|cs| cs.sub_classes(@jkci_class.sub_classes)}
    respond_to do |format|
      format.pdf { render :layout => false }
    end
  end

  def download_class_catlog
    @jkci_class = JkciClass.where(id: params[:id]).first
    raise ActionController::RoutingError.new('Not Found') unless @jkci_class
    @catlogs = @jkci_class.students_table_format(params[:subclass])
    
    respond_to do |format|
      format.pdf { render :layout => false }
    end
  end

  def download_class_syllabus
    @jkci_class = JkciClass.includes(:daily_teaching_points).where(id: params[:id]).first
    raise ActionController::RoutingError.new('Not Found') unless @jkci_class
    
    @subjects = @jkci_class.standard.subjects.includes({chapters: :chapters_points})
    @points_hash = @jkci_class.daily_teaching_points.collect {|dtp| {dtp.chapter_id => dtp.chapters_point_id.split(',').map(&:to_i) }}
    @points_hash = @points_hash.inject(:merge)
    #@subject = @jkci_class.standard.subjects.where(id: params[:subject]).first
    #@chapters_table = @jkci_class.chapters_table_format(@subject)
    respond_to do |format|
      format.pdf { render :layout => false }
    end
  end

  def download_class_student_list
    @jkci_class = JkciClass.where(id: params[:id]).first
    raise ActionController::RoutingError.new('Not Found') unless @jkci_class
    @auth_user =  current_user.has_role? :organisation
    @students_table_format = @jkci_class.class_students_table_format(@auth_user)
    
    respond_to do |format|
      format.pdf { render :layout => false }
    end
  end

  def get_timetable
    jkci_class = JkciClass.where(id: params[:id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class

    time_table = jkci_class.time_tables.where(sub_class_id: nil).first
    if time_table
      render json: {success: true, time_table: time_table.as_json, subjects: jkci_class.subjects.as_json, slots: time_table.time_table_classes.includes([:subject, :sub_class, :jkci_class, :teacher]).as_json, sub_classes: jkci_class.sub_classes.as_json}
    else
      render json: {success: false}
    end
  end

  def get_subjects
    jkci_class = JkciClass.includes({subjects: :standard}).where(id: params[:id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class

    render json: {success: true, subjects: jkci_class.subjects.as_json}
  end
  
  def get_time_table_to_verify
    jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class

    time_table = jkci_class.time_tables.where(sub_class_id: nil).first
    if time_table
      time_table_classes = time_table.time_table_classes.includes([:subject, :sub_class, :jkci_class]).where(teacher_id: nil)
      render json: {success: true,  slots: time_table_classes.map(&:verify_json)}
    else
      render json: {success: false}
    end
  end

  def get_time_table
    jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class

    time_table_classes = jkci_class.time_table_classes.includes([:subject, :sub_class, :jkci_class, :teacher]).day_wise_sort
    render json: {success: true, slots: time_table_classes, count: time_table_classes.count}
  end

  def check_verify_students
    jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    if !jkci_class.present? || !current_user.has_role?(:manage_class)
      return render json: {success: false, message: "Invalid Class"}  
    end
    class_students = jkci_class.class_students.includes(:student).where(is_duplicate: true).order("duplicate_field ASC")
    render json: {success: true, class_students: class_students.map(&:verify_student_json), total_students: jkci_class.class_students_count}
  end

  def recheck_duplicate_student
    jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    jkci_class.check_duplicates(true)
    render json: {success: true}
  end

  def accept_duplicate_student
    jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    class_student = jkci_class.class_students.where(student_id: params[:student_id]).first
    if class_student
      class_student.update_attributes({is_duplicate_accepted: true})
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def verify_students
    jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    jkci_class.update_attributes({is_student_verified: true})
    jkci_class.create_activity key: 'jkci_class.verify_student', owner: current_user, organisation_id: @organisation.id
    render json: {success: true}
  end

  def make_active_class
    jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    jkci_class.make_active_class(@organisation)
    jkci_class.create_activity key: 'jkci_class.make_active', owner: current_user, organisation_id: @organisation.id
    jkci_classes = @organisation.jkci_classes.order("id desc")
    render json: {success: true, classes: jkci_classes.map(&:organisation_class_json)}
  end

  def make_deactive_class
    jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    jkci_class.make_deactive_class(@organisation)
    jkci_class.create_activity key: 'jkci_class.make_deactive', owner: current_user, organisation_id: @organisation.id
    jkci_classes = @organisation.jkci_classes.order("id desc")
    render json: {success: true, classes: jkci_classes.map(&:organisation_class_json)}
  end


  def download_excel
    jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    raise ActionController::RoutingError.new('Not Found') unless jkci_class
    @class_code = "eraCord-#{@organisation.id}-#{jkci_class.id}"
    @students = jkci_class.students
    respond_to do |format|
      format.xlsx
    end

  end

  def import_students_excel
    jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    file = params[:file]
    if jkci_class && file
      if JkciClass.import_students_excel(file, jkci_class, @organisation)
        jkci_class.update_attributes({is_student_verified: false})
        jkci_class.check_duplicates(false)
        render json: {success: true}
      else
        render json: {success: false, message: "Please Fill Proper Data"}
      end
    else
      render json: {success: false, message: "File Not Present"}
    end
  end

  def presenty_catlog
    jkci_class = JkciClass.where(id: params[:id]).first
    if jkci_class
      catlogs = jkci_class.presenty_catlog(params[:filter], false)
      render json: {success: true, catlogs: catlogs}
    else
      render json: {success: false, message: "File Not Present"}
    end
  end

  def download_presenty_catlog
    jkci_class = JkciClass.where(id: params[:id]).first
    if jkci_class
      start_date = Date.parse(params[:start_date]).to_date rescue nil
      end_date = Date.parse(params[:end_date]).to_date rescue nil
      @catlogs = jkci_class.presenty_catlog(params[:filter], true, start_date , end_date)
    else
      @catlogs = []
    end
      
    respond_to do |format|
      format.xlsx
    end
  end

  def get_activities
    jkci_class = JkciClass.where(id: params[:id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    
    activities = PublicActivity::Activity.where("(trackable_type like 'JkciClass' && trackable_id = ?) || (recipient_type like 'JkciClass' && recipient_id = ?)", jkci_class.id, jkci_class.id)
    activities_json = activities.group_by {|a| a.created_at.strftime("%d-%m-%Y") }.collect{|key, value| {key => value.map(&:activities_json) }}.inject(:merge) || {}
    #render json: {success: true, activities: activities.map(&:json)}
    max_activities = activities_json.values.map(&:count).max rescue 0
    render json: {success: true, activities: activities_json, max_activities: max_activities}
  end

  def get_activity
    jkci_class = JkciClass.where(id: params[:id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    date = Date::strptime(params[:date], "%d-%m-%Y").in_time_zone("Kolkata").utc
    activities = PublicActivity::Activity.where("((trackable_type like 'JkciClass' && trackable_id = ?) || (recipient_type like 'JkciClass' && recipient_id = ?)) && (created_at > ? && created_at < ?)", jkci_class.id, jkci_class.id, date, date + 1.day)
    
    #render json: {success: true, activities: activities.map(&:json)}
    render json: {success: true, activities: activities.map(&:activity_json), class_name: jkci_class.class_name}
  end

  def sync_organisation_classes
    jkci_classes = JkciClass.select([:id, :class_name, :is_active, :is_current_active]).active
    render json: {success: true, jkci_classes: jkci_classes.map(&:sync_json)}
  end

  def sync_organisation_class_students
    class_students = ClassStudent.select([:id, :jkci_class_id, :student_id, :sub_class]).joins(:jkci_class).where("jkci_classes.is_current_active = ?", true)
    render json: {success: true, class_students: class_students.map(&:sync_json)}
  end
  
  def my_sanitizer
    #params.permit!
    params.require(:jkci_class).permit!
  end
end
