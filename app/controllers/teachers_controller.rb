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
    return render json: {success: false, message: "Must be root user"} unless @organisation.root?
    
    g_teacher = Teacher.get_g_teacher(create_params, @organisation)
    teacher = Teacher.new(create_params)
    teacher.g_teacher_id = g_teacher.id
    teacher.organisation_id = @organisation.id
    if teacher.save
      g_teacher.manage_registered_teacher(@organisation)
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
    if teacher && teacher.update_attributes(update_params)
      render json: {success: true, teacher_id: teacher.id}
    else
      render json: {success: false, message: teacher.present? ? teacher.errors.full_messages.join(' , ') : "Record not found"}
    end
  end

  def get_subjects
    teacher = Teacher.includes({subjects: :standard}).where(id: params[:id]).first
    if teacher
      render json: {success: true, subjects: teacher.teacher_subjects.as_json}
    else
      render json: {success: false}
    end
  end

  def get_remaining_subjects
    teacher = Teacher.where(id: params[:id]).first
    if teacher
      subjects = teacher.remaining_subjects(@organisation.root)
      render json: {success: true, subjects: subjects.as_json}
    else
      render json: {success: false}
    end
  end

  def save_subjects
    teacher = Teacher.where(id: params[:id]).first
    if teacher
      teacher.save_subjects(@organisation.root, params[:subjects].split(','))
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def remove_subjects
    teacher = Teacher.where(id: params[:id]).first
    if teacher
      teacher.remove_subject(params[:subject_id])
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def get_time_table
    teacher = Teacher.where(id: params[:id]).first

    if teacher
      timetable = teacher.time_table_classes.includes([:sub_class, :subject, :teacher, :jkci_class]).day_wise_sort
      render json: {success: true, timetable: timetable}
    else
      render json: {success: false, message: "Invalid teacher"}
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
