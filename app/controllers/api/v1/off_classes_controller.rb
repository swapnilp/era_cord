class Api::V1::OffClassesController < ApiController
    before_action :authenticate_user!
  
  def index
    teacher = current_user.teacher 
    return render json: {success: false, message: "Invalid teacher"} unless teacher
    
    off_classes = teacher.off_classes.includes([:sub_class, {subject: :standard}]).page(params[:page])
    render json: {success: true, off_classes: off_classes.as_json, count: off_classes.total_count}
  end
end
