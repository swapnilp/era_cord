class DailyTeachsController < ApplicationController
  before_action :authenticate_user!  
  load_and_authorize_resource class: 'DailyTeachingPoint', param_method: :my_sanitizer

  def index
    jkci_class = JkciClass.where(id: params[:jkci_class_id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    
    daily_teaching_points = jkci_class.daily_teaching_points.includes([:subject, :chapter]).order(id: :desc, date: :desc)
    
    if params[:filter] && JSON.parse(params[:filter])['subject'].present?
      daily_teaching_points = daily_teaching_points.where(subject_id: JSON.parse(params[:filter])['subject'])
    end

    if params[:filter] && JSON.parse(params[:filter])['dateRange'].present? && params[:filter] && JSON.parse(params[:filter])['dateRange']['startDate'].present?
      daily_teaching_points = daily_teaching_points.where("date >= ? ", JSON.parse(params[:filter])['dateRange']['startDate'].to_time)
    end

    if params[:filter] && JSON.parse(params[:filter])['dateRange'].present? && params[:filter] && JSON.parse(params[:filter])['dateRange']['endDate'].present?
      daily_teaching_points = daily_teaching_points.where("date <= ? ", JSON.parse(params[:filter])['dateRange']['endDate'].to_time)
    end
    
    daily_teaching_points = daily_teaching_points.page(params[:page])
    render json: {success: true, daily_teaching_points: daily_teaching_points.map{|dtp| dtp.as_json({}, @organisation)}, count: daily_teaching_points.total_count}
  end

  def create
    raise ActionController::RoutingError.new('Not Found') unless current_user.has_role? :create_daily_teach 
    jkci_class = JkciClass.where(id: params[:jkci_class_id]).first
    
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
    jkci_class = JkciClass.where(id: params[:jkci_class_id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    daily_teaching_point = jkci_class.daily_teaching_points.where(id: params[:id]).first
    if daily_teaching_point
      render json: {success: true, daily_teaching_point: daily_teaching_point.show_json}
    else
      render json: {success: false}
    end
  end

  def get_catlogs
    jkci_class = JkciClass.where(id: params[:jkci_class_id]).first
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
    jkci_class = JkciClass.where(id: params[:jkci_class_id]).first
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
    jkci_class = JkciClass.where(id: params[:jkci_class_id]).first
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
    jkci_class = JkciClass.where(id: params[:jkci_class_id]).first
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
    jkci_class = JkciClass.where(id: params[:jkci_class_id]).first
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
    daily_teaching_point = DailyTeachingPoint.where(id: params[:id]).first
    
    if daily_teaching_point
      daily_teaching_point.verify_presenty
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def update
    daily_teaching_point = DailyTeachingPoint.where(id: params[:id]).first
    if daily_teaching_point && daily_teaching_point.update_attributes(update_params)
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def publish_absenty
    jkci_class = JkciClass.where(id: params[:jkci_class_id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    
    daily_teaching_point = @organisation.daily_teaching_points.where(id: params[:id]).first
    if daily_teaching_point
      daily_teaching_point.publish_absenty
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  ########################
  
  

  

  def get_class_students
    @daily_teaching_point = DailyTeachingPoint.where(id: params[:id]).first
    @students = @daily_teaching_point.jkci_class.students
    @present_students = @daily_teaching_point.class_catlogs.map(&:student_id)
    render json: {html: render_to_string(:partial => "student_catlog.html.erb", :layout => false)}
  end
  
  def class_presenty
    present_students = params[:students]
    jkci_class = JkciClass.where(id: params[:id]).first
  end
  

  
  
  
  
  def filter_teach
    daily_teaching_points = @organisation.daily_teaching_points.all.page(params[:page])
    if params[:class_id].present?
      daily_teaching_points = daily_teaching_points.where(jkci_class_id: params[:class_id])
    end
    if params[:teacher].present?
      daily_teaching_points = daily_teaching_points.where(teacher_id: params[:teacher])
    end
    render json: {success: true, html: render_to_string(:partial => "daily_teach.html.erb", :layout => false, locals: {daily_teaching_points: daily_teaching_points}), pagination_html:  render_to_string(partial: 'pagination.html.erb', layout: false, locals: {daily_teaching_points: daily_teaching_points}), css_holder: ".dailyTeachTable tbody"}
  end

  
  def follow_teach
    class_catlog = @organisation.class_catlogs.where(id: params[:id]).first
    class_catlog.update_attributes({is_followed: true}) if class_catlog
    render json: {success: true}
  end

  def recover_daily_teach
    class_catlog = @organisation.class_catlogs.where(id: params[:class_catlog_id]).first
    class_catlog.update_attributes({is_recover: true, recover_date: Date.today}) if class_catlog
    render json: {success: true}
  end

  def send_class_absent_sms
    raise ActionController::RoutingError.new('Not Found') unless current_user.has_role? :publish_daily_teach_absenty
    daily_teaching_point = @organisation.daily_teaching_points.where(id: params[:id]).first
    daily_teaching_point.publish_absenty
    redirect_to jkci_class_path daily_teaching_point.jkci_class
  end

  private
  
  def my_sanitizer
    #params.permit!
    params.require(:daily_teaching_point).permit!
  end

  def create_params
    params.require(:daily_teaching_point).permit(:subject_id, :chapter_id, :date, :sub_classes, :chapters_point_id, :sub_class_id)
  end

  def update_params
    params.require(:daily_teaching_point).permit(:chapter_id, :date, :chapters_point_id)
  end
  
end
