class TimeTableClassesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource param_method: :my_sanitizer

  def index
    jkci_class = JkciClass.where(id: params[:jkci_class_id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    time_tables = jkci_class.sub_classes
    render json: {success: true, sub_classes: sub_classes.map(&:index_json)}
  end

  def create
    time_table = TimeTable.where(id: params[:time_table_id]).first
    return render json: {success: false, message: "Invalid Time table"} unless time_table
    
    time_table_class = time_table.time_table_classes.build( params[:time_table_class].merge({organisation_id: @organisation.id}))
    if time_table_class.save
      render json: {success: true, slot: time_table_class}
    else
      render json: {success: false}
    end
  end

  def show
  end

  def update
    time_table = TimeTable.where(id: params[:time_table_id]).first
    return render json: {success: false, message: "Invalid Time table"} unless time_table
    
    time_table_class = time_table.time_table_classes.where(id: params[:id]).first
    if time_table_class && time_table_class.update_attributes(update_params) 
      render json: {success: true, slot: time_table_class.as_json}
    else
      render json: {success: false}
    end
  end

  def destroy
    time_table = TimeTable.where(id: params[:time_table_id]).first
    return render json: {success: false, message: "Invalid Time table"} unless time_table
    
    time_table_class = time_table.time_table_classes.where(id: params[:id]).first
    if time_table_class && time_table_class.destroy
      render json: {success: true}
    else
      render json: {success: false}
    end
    
  end

  private
  
  def my_sanitizer
    #params.permit!
    params.require(:time_table_class).permit!
  end

  def update_params
    params.require(:time_table_class).permit(:slot_id, :subject_id, :start_time, :end_time, :durations, :cwday, :sub_class_id, :class_room)
  end
end
