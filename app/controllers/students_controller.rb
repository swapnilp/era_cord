class StudentsController < ApplicationController
  before_action :authenticate_user!
  #skip_before_filter :authenticate_with_token!, only: [:download_report]
  load_and_authorize_resource param_method: :my_sanitizer
  

  def index
    students = @organisation.students.includes(:standard, :jkci_classes, {subjects: :standard}, :batch).select([:id, :first_name, :last_name, :standard_id, :group, :mobile, :p_mobile, :enable_sms, :gender, :is_disabled, :batch_id, :parent_name]).order("id desc")
    if params[:search]
      query = "%#{params[:search]}%"
      students = students.where("CONCAT_WS(' ', first_name, last_name) LIKE ? || CONCAT_WS(' ', last_name, first_name) LIKE ? || p_mobile like ?", query, query, query)
    end
    students = students.page(params[:page])
    render json: {success: true, body: ActiveModel::ArraySerializer.new(students, each_serializer: StudentSerializer).as_json, count: students.total_count}
  end

  def new
    if params[:class_id].present?
      jkci_class = @organisation.jkci_classes.where(id: params[:class_id]).first
      if jkci_class
        standards = @organisation.standards.where(id: jkci_class.standard_id)
        subjects = standards.first.try(:subjects).try(:optional) || []  
        batches = Batch.where(id: jkci_class.batch_id)
        render json: {success: true, standards: standards, subjects: subjects.as_json, batches: batches}
      else
        render json: {success: false}
      end
    else
      standards = @organisation.standards.active
      subjects = standards.first.try(:subjects).try(:optional) || []  
      batches = Batch.all
      render json: {success: true, standards: standards, subjects: subjects.as_json, batches: batches}
    end
  end
  
  def create
    params.permit!
    student = @organisation.students.build(params[:student])
    if student.save
      student.add_students_subjects(params[:o_subjects], @organisation)
      if params[:class_id].present?
        jkci_class = @organisation.jkci_classes.where(id: params[:class_id]).first
        jkci_class.class_students.build({student_id: student.id, organisation_id: @organisation.id}).save  if jkci_class.present?
      end
      render json: {success: true}
    else
      render json: {success: false, message: students.errors.full_messages.join(' , ')}
    end
  end
  
  def show
    student = @organisation.students.includes({subjects: :standard}).where(id: params[:id]).first
    if student
      render json: {success: true, body: StudentSerializer.new(student).as_json}
    else
       render json: {success: false}
    end

  end

  def edit
    student = @organisation.students.where(id: params[:id]).first
    batches = Batch.active
    standards = @organisation.standards.active
    subjects = (@student.standard.try(:subjects).try(:optional) || @standards.first.try(:subjects)).try(:optional) || []
    if student
      render json: {success: true, student: student.as_json, standards: standards, subjects: subjects.as_json, batches: batches, o_subjects: student.subjects.optional.map(&:id)}
    else
      render json: {success: false}
    end
  end

  def update
    params.permit!
    student = @organisation.students.where(id: params[:id]).first
    if student && student.update(params[:student])
      student.add_students_subjects(params[:o_subjects], @organisation)
      render json: {success: true}
    else
      render json: {success: false}
    end
  end
  
  def toggle_sms
    student = @organisation.students.where(id: params[:id]).first
    if student && current_user.has_role?(:toggle_student_sms)
      student.update({enable_sms: params[:enable_sms]})
      render json: {success: true, enable_sms: student.enable_sms}
    else
      render json: {success: false, enable_sms: student.enable_sms}
    end
  end
  
  def download_report
    @student = @organisation.students.where(id: params[:id]).first
    @exam_catlogs = @student.exam_table_format
    @dtps = @student.class_catlogs.absent
    filename = "#{@student.name}.xls"
    respond_to do |format|
      #format.xls { headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" }
      format.pdf { render :layout => false }
    end
  end

  ##################

  def filter_students_data
    authorize! :roll, :clark
    student = @organisation.students.where(id: params[:id]).first
    includes_tables = params[:data_type] == 'exam' ? [:exam] : [:jkci_class, :daily_teaching_point]
    catlogs = student.send("#{params[:data_type].singularize}_catlogs".to_sym).includes(includes_tables).order('id desc').page(params[:page])
    respond_to do |format|
      format.html
      format.json {render json: {success: true, html: render_to_string(:partial => "students_#{params[:data_type]}.html.erb", :layout => false, locals: {catlogs: catlogs}), pagination_html: render_to_string(partial: 'filter_pagination.html.erb', layout: false, locals: {catlogs: catlogs,  params: {data_type: params[:data_type]}}), css_holder: ".#{params[:data_type]}Table tbody"}}
    end
  end
  
  


  def destroy
  end

  
  
  def enable_sms
    student = @organisation.students.select([:id, :enable_sms, :organisation_id, :p_mobile, :initl, :last_name]).where(id: params[:id]).first
    if student.present?
      student.activate_sms 
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  
  def disable_student_sms
    student = @organisation.students.select([:id, :enable_sms, :organisation_id, :p_mobile, :initl, :last_name]).where(id: params[:id]).first
    if student
      student.deactivate_sms if student
      redirect_to student_path(student), flash: {success: true, notice: "sms is deactivated successfully"} 
    else
      redirect_to students_path, flash: {success: false, notice: "Something went wrong"} 
    end
  end

  def filter_students
    students = @organisation.students.select([:id, :first_name, :last_name, :std, :group, :mobile, :p_mobile, :enable_sms, :batch_id, :gender, :is_disabled, :standard_id])
    if params[:batch_id].present?
      students = students.where(batch_id: params[:batch_id])
    end
    if params[:standard].present?
      students = students.where(standard_id: params[:standard])
    end

    if params[:filter].present?
      students = students.where("first_name like ? OR last_name like ? OR mobile like ? OR p_mobile like ?", "%#{params[:filter]}%", "%#{params[:filter]}%", "%#{params[:filter]}%", "%#{params[:filter]}%")
    end

    if params[:gender].present?
      students = students.where(gender: params[:gender])
    end
    
    students = students.order("id desc").page(params[:page])
    pagination_html = render_to_string(partial: 'pagination.html.erb', layout: false, locals: {students: students})

    render json: {success: true, html: render_to_string(:partial => "student.html.erb", :layout => false, locals: {students: students}), pagination_html:  pagination_html, css_holder: ".studentsTable tbody"}
  end

  def select_user
    users = User.where(role: 'parent')
    render json: {success: true, html: render_to_string(:partial => "user.html.erb", :layout => false, locals: {users: users})}
  end
  
  def disable_student
    student = @organisation.students.where(id: params[:id]).first
    if student
      student.update_attributes({is_disabled: true, enable_sms: false})
      student.jkci_classes.clear
      redirect_to student_path(student)
    else
      redirect_to students_path
    end
  end
  
  def enable_student
    student = @organisation.students.where(id: params[:id]).first
    if student
      student.update_attributes({is_disabled: false})
      redirect_to student_path(student)
    else
      redirect_to students_path
    end
  end

  

  private
  
  def my_sanitizer
    #params.permit!
    params.require(:student).permit!
  end

end
