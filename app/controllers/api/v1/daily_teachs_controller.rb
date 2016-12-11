class Api::V1::DailyTeachsController < ApplicationController
  before_action :authenticate_user!  
  
  load_and_authorize_resource class: 'DailyTeachingPoint', param_method: :my_sanitizer

  def index
    teacher = current_user.teacher
    return render json: {success: false, message: "Invalid teacher"} unless teacher
    
    daily_teaching_points = teacher.daily_teaching_points.includes([:subject, :chapter, :class_catlogs, :jkci_class]).order(id: :desc, date: :desc).page(params[:page])
    render json: {success: true, daily_teaching_points: daily_teaching_points.map{|dtp| dtp.as_json({}, @organisation)}, count: daily_teaching_points.total_count}
  end

  def create
    time_table_class = TimeTableClass.where(id: params[:time_table_class_id]).first
    return render json: {success: false, message: "Invalid time table"} unless time_table_class
    
    teacher = current_user.teacher
    return render json: {success: false, message: "Invalid teacher"} unless teacher
    
    daily_teaching_point = time_table_class.jkci_class.daily_teaching_points.build(create_params.merge({organisation_id: @organisation.id, subject_id: time_table_class.subject_id,
sub_classes: time_table_class.sub_class_id, teacher_id: teacher.id}))
    
    if daily_teaching_point.save
      daily_teaching_point.create_catlog
      render json: {success: true, dtp_id: daily_teaching_point.id }
    else
      render json: {success: false}
    end
  end

  def show
    teacher = current_user.teacher
    return render json: {success: false, message: "Invalid teacher"} unless teacher
    
    daily_teaching_point = teacher.daily_teaching_points.where(id: params[:id]).first
    if daily_teaching_point
      render json: {success: true, daily_teaching_point: daily_teaching_point.as_json}
    else
      render json: {success: false}
    end
  end

  def get_catlogs
    teacher = current_user.teacher
    return render json: {success: false, message: "Invalid teacher"} unless teacher
    
    daily_teaching_point = teacher.daily_teaching_points.where(id: params[:id]).first
    if daily_teaching_point
      catlogs = daily_teaching_point.students.map{|student| student.catlog_json([daily_teaching_point.class_catlogs.map(&:student_id)])}
      render json: {success: true, class_catlogs: catlogs}
    else
      render json: {success: false}
    end
  end
  
  def save_catlogs
    teacher = current_user.teacher
    return render json: {success: false, message: "Invalid teacher"} unless teacher
    
    daily_teaching_point = teacher.daily_teaching_points.where(id: params[:id]).first
    if daily_teaching_point
      if params[:daily_teaching_point].present?
        daily_teaching_point.fill_catlog(params[:daily_teaching_point][:absenty_string].split(',').map(&:to_i),  Date.today)
      end
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  private
  
  def my_sanitizer
    #params.permit!
    params.require(:daily_teaching_point).permit!
  end

  def create_params
    params.require(:daily_teaching_point).permit(:chapter_id, :date, :chapters_point_id)
  end

  def update_params
    params.require(:daily_teaching_point).permit(:chapter_id, :date, :chapters_point_id)
  end
  
end
