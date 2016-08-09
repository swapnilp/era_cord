class Api::V1::JkciClassesController < ApiController
  before_action :authenticate_user!

  
  before_action :active_standards!, only: [:index]
  #skip_before_filter :authenticate_with_token!, only: [:sub_organisation_class_report]
  load_and_authorize_resource param_method: :my_sanitizer, except: [:sync_organisation_classes, :sync_organisation_class_students]


  def index
    teacher = current_user.teacher
    if teacher.present?
      jkci_classes = teacher.jkci_classes.where(standard_id: @active_standards).active.uniq.order("id desc")
      render json: {success: true, classes: ActiveModel::ArraySerializer.new(jkci_classes, each_serializer: JkciClassIndexSerializer).as_json, teacher_id: teacher.try(:id)}
    else
      render json: {success: false, message: "You are not a teacher for that organisations"}
    end
  end

  def get_dtp_info
    teacher = current_user.teacher
    if teacher.present?
      time_table_classes = teacher.time_table_classes.joins(:time_table).where("time_tables.jkci_class_id = ?", params[:id])
      render json: {success: true, time_table_classes: time_table_classes.map(&:teacher_json)} 
    else
      render json: {success: false}
    end
  end
    
  
  def my_sanitizer
    #params.permit!
    params.require(:jkci_class).permit!
  end
end

