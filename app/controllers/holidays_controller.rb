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
  
  def create
    
    holiday = Holiday.new(create_params.merge({organisation_id: @organisation.id, is_goverment: false}))
    if holiday.save
      render json: {success: true}
    else
      render json: {success: false}
    end
  end
    
  private

  def create_params
    params.require(:holiday).permit(:date, :reason)
  end

  def update_params
    params.require(:holiday).permit(:date, :reason)
  end
end
