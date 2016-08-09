class Api::V1::DailyTeachsController < ApplicationController
  before_action :authenticate_user!  
  
  load_and_authorize_resource class: 'DailyTeachingPoint', param_method: :my_sanitizer

  def index
    jkci_class = JkciClass.where(id: params[:jkci_class_id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    
    daily_teaching_points = jkci_class.daily_teaching_points.includes([:subject, :chapter, :class_catlogs]).order("date desc").page(params[:page])
    render json: {success: true, daily_teaching_points: daily_teaching_points.map{|dtp| dtp.as_json({}, @organisation)}, count: daily_teaching_points.total_count}
  end

  def create
    raise ActionController::RoutingError.new('Not Found') unless current_user.has_role? :create_daily_teach 
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
    
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    daily_teaching_point = jkci_class.daily_teaching_points.build(create_params.merge({organisation_id: @organisation.id}))
    
    if daily_teaching_point.save
      #daily_teaching_point.create_catlog
      render json: {success: true, class_id: jkci_class.id, dtp_id: daily_teaching_point.id}
    else
      render json: {success: false}
    end
  end

  def show
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    daily_teaching_point = jkci_class.daily_teaching_points.where(id: params[:id]).first
    if daily_teaching_point
      render json: {success: true, daily_teaching_point: daily_teaching_point}
    else
      render json: {success: false}
    end
  end

  def get_catlogs
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    daily_teaching_point = jkci_class.daily_teaching_points.where(id: params[:id]).first
    if daily_teaching_point
      catlogs = daily_teaching_point.students.map{|student| student.catlog_json([daily_teaching_point.class_catlogs.map(&:student_id)])}
      render json: {success: true, class_catlogs: catlogs}
    else
      render json: {success: false}
    end
  end
  
  def fill_catlog
    raise ActionController::RoutingError.new('Not Found') unless current_user.has_role? :add_daily_teach_absenty
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    daily_teaching_point = jkci_class.daily_teaching_points.where(id: params[:id]).first
    if daily_teaching_point
      daily_teaching_point.fill_catlog(params[:students], Time.now)
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def add_absent_student
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    daily_teaching_point = jkci_class.daily_teaching_points.where(id: params[:id]).first
    if daily_teaching_point
      daily_teaching_point.make_absent(params[:student])
      render json: {success: true}
    else
      render json: {success: false}
    end
  end
  
  def remove_absent_student
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    daily_teaching_point = jkci_class.daily_teaching_points.where(id: params[:id]).first
    if daily_teaching_point
      daily_teaching_point.remove_absent(params[:student])
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def edit
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    
    daily_teaching_point = jkci_class.daily_teaching_points.where(id: params[:id]).first
    if daily_teaching_point
      chapters = daily_teaching_point.subject.chapters
      chapters_points = daily_teaching_point.chapter.try(:chapters_points)
      render json: {success: true, chapters_points: chapters_points, chapters: chapters, daily_teaching_point: daily_teaching_point.edit_json}
    else
      render json: {success: false}
    end
  end

  def class_absent_verification
    return render json: {success: false, message: "Unauthorised"} unless current_user.has_role? :verify_daily_teach_absenty
    daily_teaching_point = @organisation.daily_teaching_points.where(id: params[:id]).first
    
    if daily_teaching_point
      daily_teaching_point.verify_presenty
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def update
    daily_teaching_point = @organisation.daily_teaching_points.where(id: params[:id]).first
    if daily_teaching_point && daily_teaching_point.update_attributes(update_params)
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def publish_absenty
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    
    daily_teaching_point = @organisation.daily_teaching_points.where(id: params[:id]).first
    if daily_teaching_point
      daily_teaching_point.publish_absenty
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
    params.require(:daily_teaching_point).permit(:subject_id, :chapter_id, :date, :sub_classes, :chapters_point_id)
  end

  def update_params
    params.require(:daily_teaching_point).permit(:chapter_id, :date, :chapters_point_id)
  end
  
end
