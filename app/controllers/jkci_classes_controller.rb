class JkciClassesController < ApplicationController
  before_action :authenticate_user!, except: [:sync_organisation_classes, :sync_organisation_class_students]
  before_action :authenticate_organisation!, only: [:sync_organisation_classes, :sync_organisation_class_students]
  
  before_action :active_standards!, only: [:index]
  #skip_before_filter :authenticate_with_token!, only: [:sub_organisation_class_report]
  load_and_authorize_resource param_method: :my_sanitizer, except: [:sync_organisation_classes, :sync_organisation_class_students]

  skip_before_filter :authenticate_with_token!, only: [:sync_organisation_classes, :sync_organisation_class_students]
  skip_before_filter :verify_authenticity_token, only: [:sync_organisation_classes, :sync_organisation_class_students]
  skip_before_filter :require_no_authentication, :only => [:sync_organisation_classes, :sync_organisation_class_students]
  before_action :authenticate_organisation!, only: [:sync_organisation_classes, :sync_organisation_class_students]
  before_filter :authenticate_org_with_token!, only: [:sync_organisation_classes, :sync_organisation_class_students]

  def index
    jkci_classes = @organisation.jkci_classes.where(standard_id: @active_standards).active.order("id desc")
    #jkci_classes = @organisation.standards.where("organisation_standards.is_assigned_to_other = false").map(&:jkci_classes).map(&:last)
    render json: {body: ActiveModel::ArraySerializer.new(jkci_classes, each_serializer: JkciClassIndexSerializer).as_json}
  end

  def get_unassigned_classes
    #jkci_classes = @organisation.standards.where("organisation_standards.is_assigned_to_other = true").map(&:jkci_classes).map(&:last)
    jkci_classes = JkciClass.where("id not in (?) && is_current_active = ? && standard_id in (?)", @organisation.jkci_classes.map(&:id) << 0, true, @organisation.organisation_standards.map(&:standard_id) << 0)#@organisation.descendants.map(&:jkci_classes).map(&:active).flatten
    render json: {body: jkci_classes.map(&:unassigned_json)}
  end

  def get_exam_info
    jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    if jkci_class
      render json: {success: true, data: ClassExamDataSerializer.new(jkci_class).as_json} 
    else
      render json: {success: false}
    end
  end

  def get_dtp_info
    jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    if jkci_class
      render json: {success: true, data: ClassExamDataSerializer.new(jkci_class).as_json} 
    else
      render json: {success: false}
    end
  end

  def show
    jkci_class = JkciClass.where(id: params[:id]).first
    #@notifications = @jkci_class.role_exam_notifications(current_user)
    if jkci_class
      render json: JkciClassSerializer.new(jkci_class).as_json.merge({success: true, has_manage_class: (current_user.has_role? :manage_class), self_organisation: jkci_class.organisation_id == @organisation.id})
    else
      render json: {success: false}
    end
  end

  def toggle_class_sms
    jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    if jkci_class && current_user.has_role?(:manage_class_sms)
      jkci_class.update_attributes({enable_class_sms: params[:value]})
      render json: {success: true, id: jkci_class.id}
    else
      render json: {success: false, message: "Some thing went wrong"}
    end
  end

  def toggle_exam_sms
    jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    if jkci_class && current_user.has_role?(:manage_class_sms)
      jkci_class.update_attributes({enable_exam_sms: params[:value]})
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
    students = jkci_class.students.includes({subjects: :standard}, :standard, :batch, :jkci_classes).select("class_students.roll_number, students.*")
    if params[:search]
      query = "%#{params[:search]}%"
      students = students.where("CONCAT_WS(' ', first_name, last_name) LIKE ? || CONCAT_WS(' ', last_name, first_name) LIKE ? || p_mobile like ?", query, query, query)
    end
    unless params[:withoutPage]
      students = students.page(params[:page])
    end
    roles = current_user.roles.map(&:name)
    render json: {success: true, students: ActiveModel::ArraySerializer.new(students, each_serializer: StudentSerializer).as_json, count: students.try(:total_count), has_show_pay_info: roles.include?('accountant'), has_pay_fee: (['accountant','accountant_clark'] & roles).size > 0}
  end

  def remove_student_from_class
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    if jkci_class
      jkci_class.remove_student_from_class(params[:student_id], @organisation) 
      jkci_class.update_attributes({is_student_verified: false})
      jkci_class.check_duplicates(false)
      render json: {success: true, id: jkci_class.id}
    else
      render json: {success: false}
    end
  end

  def get_chapters
    jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    
    chapters = jkci_class.subjects.where(id:  params[:subject_id]).first.chapters.select([:id, :name, :chapt_no])
    render json: {success: true, chapters: chapters} 
  end

  def manage_student_subject
    jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    subjects = jkci_class.subjects.optional
    students = jkci_class.class_students
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

  def download_class_catlog
    @jkci_class = JkciClass.where(id: params[:id]).first
    raise ActionController::RoutingError.new('Not Found') unless @jkci_class
    @catlogs = @jkci_class.students_table_format(params[:subclass])
    
    respond_to do |format|
      format.pdf { render :layout => false }
    end
  end

  def download_class_syllabus
    @jkci_class = JkciClass.where(id: params[:id]).first
    raise ActionController::RoutingError.new('Not Found') unless @jkci_class
    
    @subjects = @jkci_class.standard.subjects
    #@subject = @jkci_class.standard.subjects.where(id: params[:subject]).first
    #@chapters_table = @jkci_class.chapters_table_format(@subject)
    respond_to do |format|
      format.pdf { render :layout => false }
    end
  end

  def download_class_student_list
    @jkci_class = JkciClass.where(id: params[:id]).first
    raise ActionController::RoutingError.new('Not Found') unless @jkci_class
    @students_table_format = @jkci_class.class_students_table_format
    
    respond_to do |format|
      format.pdf { render :layout => false }
    end
  end

  def get_timetable
    jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class

    time_table = jkci_class.time_tables.where(sub_class_id: nil).first
    if time_table
      render json: {success: true, time_table: time_table.as_json, subjects: jkci_class.subjects.as_json, slots: time_table.time_table_classes.as_json, subjects: jkci_class.subjects.as_json, sub_classes: jkci_class.sub_classes.as_json}
    else
      render json: {success: false}
    end
    
  end

  def check_verify_students
    jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    if !jkci_class.present? || !current_user.has_role?(:manage_class)
      return render json: {success: false, message: "Invalid Class"}  
    end
    class_students = jkci_class.class_students.includes(:student).order("duplicate_field ASC")
    render json: {success: true, class_students: class_students.map(&:verify_student_json)}
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
    render json: {success: true}
  end

  def make_active_class
    jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    jkci_class.make_active_class(@organisation)
    jkci_classes = @organisation.jkci_classes.order("id desc")
    render json: {success: true, classes: jkci_classes.map(&:organisation_class_json)}
  end

  def make_deactive_class
    jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    jkci_class.make_deactive_class(@organisation)
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

  def sync_organisation_classes
    jkci_classes = JkciClass.select([:id, :class_name, :is_active, :is_current_active]).active
    render json: {success: true, jkci_classes: jkci_classes.map(&:sync_json)}
  end

  def sync_organisation_class_students
    class_students = ClassStudent.select([:id, :jkci_class_id, :student_id, :sub_class]).joins(:jkci_class).where("jkci_classes.is_current_active = ?", true)
    render json: {success: true, class_students: class_students.map(&:sync_json)}
  end

  ####################################
  
  def create
    params.permit!
    @jkci_class = @organisation.jkci_classes.build(params[:jkci_class])
    if @jkci_class.save
      redirect_to jkci_classes_path
    end
  end

  def edit
    @jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    @teachers = @organisation.teachers
    @batches = Batch.all
  end


  

  

  
  
  

  

  
  
  def update
    params.permit!
    @jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    if @jkci_class
      if @jkci_class.update(params[:jkci_class])
        redirect_to jkci_classes_path
      end
    end
  end
  
  def destroy
    jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    if jkci_class.destroy
      redirect_to jkci_classes_path
    end
  end


  


  def class_daily_teaches
    jkci_class = @organisation.jkci_classes.includes([:daily_teaching_points, :class_catlogs]).where(id: params[:id]).first
    @daily_teaching_points = jkci_class.daily_teaching_points.order('id desc')
    if params[:chapters].present?
      @daily_teaching_points = @daily_teaching_points.where(chapter_id: params[:chapters].split(',').map(&:to_i))
    end
    @daily_teaching_points = @daily_teaching_points.page(params[:page])
    respond_to do |format|
      format.html
      format.json {render json: {success: true, html: render_to_string(:partial => "daily_teaching_point.html.erb", :layout => false, locals: {daily_teaching_points: @daily_teaching_points}), pagination_html:  render_to_string(partial: 'daily_teach_pagination.html.erb', layout: false, locals: {class_daily_teach: @daily_teaching_points}),  css_holder: ".dailyTeach"}}
    end
  end
  
  def filter_class_exams
    @jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    @class_exams = @jkci_class.jk_exams.order("updated_at desc").page(params[:page])
    respond_to do |format|
      format.html
      format.json {render json: {success: true, html: render_to_string(:partial => "/exams/exam.html.erb", :layout => false, locals: {exams: @class_exams}), pagination_html:  render_to_string(partial: 'exam_pagination.html.erb', layout: false, locals: {class_exams: @class_exams}), css_holder: ".examsTable tbody"}}
    end
  end

  def filter_daily_teach
    @jkci_class = @organisation.jkci_classes.where(id: params[:id]).first
    @daily_teaching_points = @jkci_class.daily_teaching_points.includes(:class_catlogs).chapters_points.order('id desc')
    if params[:chapters].present?
      @daily_teaching_points = @daily_teaching_points.where(chapter_id: params[:chapters].split(',').map(&:to_i))
    end
    @daily_teaching_points = @daily_teaching_points.page(params[:page])
    respond_to do |format|
      format.html
      format.json {render json: {success: true, html: render_to_string(:partial => "daily_teaching_point.html.erb", :layout => false, locals: {daily_teaching_points: @daily_teaching_points, hide_edit: true}), pagination_html:  render_to_string(partial: 'daily_teach_pagination.html.erb', layout: false, locals: {class_daily_teach: @daily_teaching_points}), css_holder: ".dailyTeach tbody"}}
    end
  end


  
  
  def my_sanitizer
    #params.permit!
    params.require(:jkci_class).permit!
  end
end
