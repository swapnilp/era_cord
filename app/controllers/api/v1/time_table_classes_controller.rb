class Api::V1::TimeTableClassesController < ApiController
  before_action :authenticate_user!

  def index
    teacher = current_user.teacher 
    return render json: {success: false, message: "Invalid teacher"} unless teacher
    time_table_classes = teacher.time_table_classes.includes([:sub_class, :jkci_class, :time_table, :subject])
    render json: {success: true, time_table_classes: time_table_classes.map(&:teacher_json)} 
  end

  def get_chapters
    teacher = current_user.teacher 
    return render json: {success: false, message: "Invalid teacher"} unless teacher
    time_table_class = teacher.time_table_classes.where(id: params[:id]).first
    if time_table_class.present?
      chapters = time_table_class.subject.chapters.select([:id, :name, :chapt_no])
      render json: {success: true, chapters: chapters.as_json} 
    else
      render json: {success: false, message: "Invalid Class"}
    end
  end

  def get_chapters_point
    teacher = current_user.teacher 
    return render json: {success: false, message: "Invalid teacher"} unless teacher
    time_table_class = teacher.time_table_classes.where(id: params[:id]).first
    chapter = Chapter.where(id: params[:chapter_id]).first
    if time_table_class.present? && chapter.present?
      points = chapter.chapters_points.select([:id, :name, :point_id])
      render json: {success: true, points: points.as_json} 
    else
      render json: {success: false, message: "Invalid Class"}
    end
  end
end
