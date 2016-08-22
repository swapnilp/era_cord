class Api::V1::StudentsController  < ApiController
  before_action :authenticate_user!
 
  
  def index
    students = Student.includes(:standard, :jkci_classes, :batch, :removed_class_students).select([:id, :first_name, :last_name, :middle_name, :standard_id, :group, :mobile, :p_mobile, :enable_sms, :gender, :is_disabled, :batch_id, :parent_name, :hostel_id]).order("id desc")
    
    if params[:search]
      query = "%#{params[:search]}%"
      students = students.where("CONCAT_WS(' ', first_name, last_name) LIKE ? || CONCAT_WS(' ', last_name, first_name) LIKE ? || p_mobile like ?", query, query, query)
    end
    
    if params[:class_id]
      students = students.joins(:class_students).where("class_students.jkci_class_id = ?", params[:class_id])
    end
    
    students = students.page(params[:page])
    roles = current_user.roles.map(&:name)
    render json: {success: true, students: ActiveModel::ArraySerializer.new(students, each_serializer: StudentSerializer).as_json, count: students.total_count, has_show_pay_info: roles.include?('accountant'), has_pay_fee: (['accountant','accountant_clark'] & roles).size > 0}
  end

end
