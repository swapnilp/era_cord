class Api::V1::TimeTablesController < ApiController
  before_action :authenticate_user!

  def get_time_tables
    teacher = current_user.teacher 
    return render json: {success: false, message: "Invalid teacher"} unless teacher

    timetable = teacher.time_table_classes.includes([:sub_class, :subject, :teacher, :jkci_class]).day_wise_sort
    render json: {success: true, timetable: timetable, count: timetable.count}
    
  end
end
