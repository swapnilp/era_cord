class HolidaysController < ApplicationController
  before_action :authenticate_user!
 
  #skip_before_filter :authenticate_with_token!, only: [:download_report]
  load_and_authorize_resource param_method: :my_sanitizer
  
  def index
    holidays = Holiday.all
    if params[:filter].present? &&  JSON.parse(params[:filter])['dateRange'].present? && JSON.parse(params[:filter])['dateRange']['startDate'].present?
      holidays = holidays.where("date >= ?", JSON.parse(params[:filter])['dateRange']['startDate'].to_time)
    end
    if params[:filter].present? &&  JSON.parse(params[:filter])['dateRange'].present? && JSON.parse(params[:filter])['dateRange']['endDate'].present?
      holidays = holidays.where("date <= ?", JSON.parse(params[:filter])['dateRange']['endDate'].to_time)
    end
    holidays = holidays.page(params[:page])
    
    render json: {success: true, holidays: holidays.as_json, total_count: holidays.total_count}
  end
  
    
  private

  def create_params
    params.require(:hostel).permit(:name, :gender, :rooms, :owner, :address, :average_fee, :student_occupancy, :is_service_tax, :service_tax, :months, :start_month)
  end

  def update_params
    params.require(:hostel).permit(:name, :gender, :rooms, :owner, :address, :average_fee, :student_occupancy, :is_service_tax, :service_tax)
  end
end
