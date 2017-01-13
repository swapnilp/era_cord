class TeachersController < ApplicationController
  before_action :authenticate_user!, except: [:sync_organisation_students]
 
  #skip_before_filter :authenticate_with_token!, only: [:download_report]
  load_and_authorize_resource param_method: :my_sanitizer
  
  def index
    #return render json: {success: false, message: "Must be root user"} unless @organisation.root?
    
    teachers = Teacher.active
    render json: {success: true, teachers: teachers.as_json}
  end
  
  def new
    
  end
  
  def create
    return render json: {success: false, message: "Must be root user"} unless @organisation.root?
    
    g_teacher = Teacher.get_g_teacher(create_params, @organisation)
    teacher = Teacher.where(email: create_params[:email]).first_or_initialize
    teacher.first_name = create_params[:first_name]
    teacher.last_name = create_params[:last_name]
    teacher.mobile = create_params[:mobile]
    teacher.address = create_params[:address]
    teacher.g_teacher_id = g_teacher.id
    
    teacher.organisation_id = @organisation.id
    teacher.active = true
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
    return render json: {success: false, message: "Must be root user"} unless @organisation.root?
    teacher = Teacher.where(id: params[:id]).first
    if teacher
      render json: {success: true, teacher: teacher.edit_json}
    else
      render json: {success: false}
    end
  end

  def update
    return render json: {success: false, message: "Must be root user"} unless @organisation.root?
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

  def daily_teachs
    teacher = Teacher.where(id: params[:id]).first
    if teacher
      dtps = teacher.daily_teaching_points.includes(:jkci_class, :subject, :chapter).order("id desc").page(params[:page])
      render json: {success: true, daily_teaching_points: dtps.as_json, count: dtps.total_count}
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
    return render json: {success: false, message: "Must be root user"} unless @organisation.root?
    
    teacher = Teacher.where(id: params[:id]).first
    if teacher
      teacher.save_subjects(@organisation.root, params[:subjects].split(','))
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def remove_subjects
    return render json: {success: false, message: "Must be root user"} unless @organisation.root?
    
    teacher = Teacher.where(id: params[:id]).first
    if teacher
      teacher.remove_subject(params[:subject_id])
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def destroy
    return render json: {success: false, message: "Must be root user"} unless @organisation.root?
    
    teacher = @organisation.teachers.where(id: params[:id]).first
    if teacher.present?
      teacher.user.delete_user("teacher") if teacher.user.present?
      teacher.time_table_classes.update_all({teacher_id: nil})
      teacher.update_attributes({active: false})
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def get_time_table
    teacher = Teacher.where(id: params[:id]).first

    if teacher
      timetable = teacher.time_table_classes.includes([:sub_class, :subject, :teacher, :jkci_class]).day_wise_sort
      render json: {success: true, timetable: timetable, count: timetable.count}
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
