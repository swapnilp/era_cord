class StudentsController < ApplicationController
  before_action :authenticate_user!
  #skip_before_filter :authenticate_with_token!, only: [:download_report]
  load_and_authorize_resource param_method: :my_sanitizer
  

  def index
    students = Student.includes(:standard, :jkci_classes, {subjects: :standard}, :batch).select([:id, :first_name, :last_name, :standard_id, :group, :mobile, :p_mobile, :enable_sms, :gender, :is_disabled, :batch_id, :parent_name]).order("id desc")
    if params[:search]
      query = "%#{params[:search]}%"
      students = students.where("CONCAT_WS(' ', first_name, last_name) LIKE ? || CONCAT_WS(' ', last_name, first_name) LIKE ? || p_mobile like ?", query, query, query)
    end
    if params[:class_id]
      students = students.joins(:class_students).where("class_students.jkci_class_id = ?", params[:class_id])
    end
    students = students.page(params[:page])
    roles = current_user.roles.map(&:name)
    render json: {success: true, body: ActiveModel::ArraySerializer.new(students, each_serializer: StudentSerializer).as_json, count: students.total_count, has_show_pay_info: roles.include?('accountant'), has_pay_fee: (['accountant','accountant_clark'] & roles).size > 0}
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
      batches = Batch.all.active
      render json: {success: true, standards: standards, subjects: subjects.as_json, batches: batches}
    end
  end
  
  def create
    #student = @organisation.students.build(params[:student])
    student = @organisation.students.find_or_initialize_by(create_params.slice(:first_name, :middle_name, :last_name, :mobile, :p_mobile, :standard_id))
    if params[:class_id].present?
      jkci_class = @organisation.jkci_classes.where(id: params[:class_id]).first
      student.batch_id = jkci_class.batch_id
    else
      student.batch_id = create_params[:batch_id]
      jkci_class = @organisation.jkci_classes.where(standard_id: create_params[:standard_id], batch_id: create_params[:batch_id]).active.last
    end
    if student.save
      student.update_attributes(create_params.slice(:gender, :initl, :parent_name))
      student.add_students_subjects(params[:o_subjects], @organisation)
      if jkci_class.present?
        class_student = jkci_class.class_students.find_or_initialize_by({student_id: student.id, organisation_id: @organisation.id})
        class_student.batch_id = jkci_class.batch_id
        class_student.save 
      end
      render json: {success: true, student_id: student.id}
    else
      render json: {success: false, message: student.errors.full_messages.join(' , ')}
    end
  end
  
  def show
    student = Student.includes({subjects: :standard}).where(id: params[:id]).first
    if student
      roles = current_user.roles.map(&:name)
      render json: {success: true, body: StudentSerializer.new(student).as_json, has_show_pay_info: roles.include?('accountant'), has_pay_fee: (['accountant','accountant_clark'] & roles).size > 0, classes: student.jkci_classes.map(&:student_filter_json) }
    else
       render json: {success: false}
    end

  end

  def edit
    student = Student.where(id: params[:id]).first
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
    student = @organisation.students.where(id: params[:id]).first
    if student && student.update(update_params)
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
  
  def get_filter_values
    jkci_classes = JkciClass.active
    render json: {success: true, classes: jkci_classes.map(&:student_filter_json)}
  end
  
  def get_graph_data
    student = Student.where(id: params[:id]).first
    
    if student
      if params[:type] == 'all'
        keys, values = student.exams_graph_reports(params[:time_zone], params[:type])
        values = [values];
      else
        keys, header, values = student.exams_graph_reports_by_subject(params[:time_zone])
      end
      render json: {success: true, keys: keys, values: values, header: header}
    else
      render json: {success: false}
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

  def get_fee_info 
    if current_user && (ACCOUNT_HANDLE_ROLES && current_user.roles.map(&:name)).size >0
      student = Student.where(id: params[:id]).first
      if student.present?
        render json: {success: true, jkci_classes: student.class_students.map(&:fee_info_json) + student.removed_class_students.map(&:fee_info_json), name: student.name, p_mobile: student.p_mobile, mobile: student.mobile, batch: student.batch.name, enable_tax: @organisation.enable_service_tax, service_tax: @organisation.service_tax}
      else
        render json: {success: false, message: "Student not present"}
      end
    else
       render json: {success: false, message: "Not Authorised"}
    end
  end

  def paid_student_fee
    if current_user && (ACCOUNT_HANDLE_ROLES && current_user.roles.map(&:name)).size >0
      if !current_user.valid_password?(params[:student_fee][:password])
        return render json: {success: false, valid_password: false, message: "Please Enter valid password"}
      end
      student = Student.where(id: params[:id]).first
      return render json: {success: false, valid_password: false, message: "Student not present"} unless student.present?
      params_data = pay_fee_params
      student_fee = student.student_fees.build(params_data)
      student_fee.batch_id = student_fee.try(:jkci_class).try(:batch_id)
      student_fee.date = Date.today
      student_fee.organisation_id = @organisation.id
      student_fee.user_id = current_user.id
      if @organisation.enable_service_tax && student_fee.is_fee
        student_fee.service_tax = (student_fee.amount.to_f * (@organisation.service_tax / 100))
        student_fee.amount = student_fee.amount
      end
      
      if student_fee.save
        if student_fee.jkci_class_id.present?
          amount = StudentFee.where(student_id: student_fee.student_id, jkci_class_id: student_fee.jkci_class_id, is_fee: true).map(&:amount).sum
          other_amount = StudentFee.where(student_id: student_fee.student_id, jkci_class_id: student_fee.jkci_class_id, is_fee: false).map(&:amount).sum
          class_student = student_fee.class_student || student_fee.removed_class_student
          class_student.update_attributes({collected_fee: amount, other_fee: other_amount})
        end
        render json: {success: true, message: "Fee is Paid", student_id: student_fee.student_id, receipt_id: student_fee.id }
      else
        render json: {success: false, message: "Something went wrong"}
      end
    else
       render json: {success: false, valid_password: true, message: "Not Authorised", valid_password: true}
    end
  end

  def get_payments_info 
    if current_user && (FULL_ACCOUNT_HANDLE_ROLES && current_user.roles.map(&:name)).size >0
      student = Student.where(id: params[:id]).first
      if student.present?
        total_amount = student.student_fees.map(&:amount).sum + student.student_fees.map(&:service_tax).sum
        render json: {success: true, jkci_classes: student.class_students.map(&:fee_info_json), name: student.name, p_mobile: student.p_mobile, mobile: student.mobile, batch: student.batch.name, payments: student.student_fees.as_json, total_fee: total_amount, id: student.id}
      else
        render json: {success: false, message: "Student not present"}
      end
    else
      render json: {success: false, message: "Not Authorised"}
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
  
  def pay_fee_params
    params.require(:student_fee).permit(:student_id, :jkci_class_id, :amount, :payment_type, :bank_name, :cheque_number, :cheque_issue_date, :book_number, :receipt_number, :is_fee, :reason)
  end

  def create_params
    params.require(:student).permit(:first_name, :last_name, :email, :mobile, :parent_name, :p_mobile, :p_email, :address, :rank, :middle_name, :batch_id, :gender, :initl, :standard_id, :parent_occupation)
  end

  def update_params
    params.require(:student).permit(:first_name, :last_name, :email, :mobile, :parent_name, :p_mobile, :p_email, :address, :rank, :middle_name, :batch_id, :gender, :initl, :standard_id, :parent_occupation)
  end

end
