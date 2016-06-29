class TeachersController < ApplicationController
  before_action :authenticate_user!, except: [:sync_organisation_students]
 
  #skip_before_filter :authenticate_with_token!, only: [:download_report]
  load_and_authorize_resource param_method: :my_sanitizer
  

  def index
    teachers = Teacher.all
    render json: {success: true, teachers: teachers.as_json}
  end
  
  def new
    
  end
  
  def create
    teacher = Teacher.new(create_params)
    teacher.organisation_id = @organisation.id
    if teacher.save
      render json: {success: true, teacher_id: teacher.id}
    else
      render json: {success: false, message: teacher.errors.full_messages.join(' , ')}
    end
  end

  def show
    teacher = Teacher.where(id: params[:id]).first
    if teacher
      render json: {success: true, teacher: teacher.as_json}
    else
      render json: {success: false}
    end
  end


  def edit
    teacher = Teacher.where(id: params[:id]).first
    if teacher
      render json: {success: true, teacher: teacher.edit_json}
    else
      render json: {success: false}
    end
  end

  def update
    teacher = Teacher.where(id: params[:id]).first
    if teacher.update_attributes(update_params)
      render json: {success: true, teacher_id: teacher.id}
    else
      render json: {success: false, message: teacher.errors.full_messages.join(' , ')}
    end
  end
  
  private
  
  
  def create_params
    params.require(:teacher).permit(:first_name, :last_name, :email, :mobile, :is_full_time)
  end

  def update_params
    params.require(:teacher).permit(:first_name, :last_name, :mobile, :is_full_time)
  end
end
