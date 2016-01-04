class TimeTablesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource param_method: :my_sanitizer

  def index
    jkci_class = JkciClass.where(id: params[:jkci_class_id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    time_tables = jkci_class.sub_classes
    render json: {success: true, sub_classes: sub_classes.map(&:index_json)}
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
