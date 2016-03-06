class TimeTablesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource param_method: :my_sanitizer

  def index
    jkci_class = JkciClass.where(id: params[:jkci_class_id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    time_tables = jkci_class.sub_classes
    render json: {success: true, sub_classes: sub_classes.map(&:index_json)}
  end

  def calender_index
    time_table_classes = TimeTableClass.includes({subject: :standard}, :sub_class).joins(time_table: :jkci_class).where("jkci_classes.is_current_active = ? and time_table_classes.organisation_id in (?) ", true, Organisation.current_id)

    if params[:standard]
      jkci_class  = JkciClass.select([:id, :standard_id, :organisation_id, :is_current_active]).where(standard_id: params[:standard], is_current_active: true).first
      time_table_classes = time_table_classes.where("jkci_classes.id = ?",  jkci_class.id)
    end
    
    render json: {success: true, time_table_classes: time_table_classes.map(&:calender_json)}
  end

  def create
    jkci_class = JkciClass.where(id: params[:jkci_class_id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    time_table = jkci_class.time_tables.build({start_time: params[:start_time], organisation_id: @organisation.id})
    if time_table.save
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def show
  end

  private
  
  def my_sanitizer
    #params.permit!
    params.require(:time_table).permit!
  end
end
