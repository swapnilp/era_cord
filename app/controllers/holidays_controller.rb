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
    return render json: {success: false, message: "Must be root user"} unless @organisation.root?
    
    if create_params[:isMultiDate]
      (JSON.parse(params['dateRange'])['startDate'].to_time.to_date..JSON.parse(params['dateRange'])['endDate'].to_time.to_date ).to_a.each do |date| 
        Holiday.new({date: date, reason: create_params[:reason], organisation_id: @organisation.id, is_goverment: false}).save
      end
      render json: {success: true}
    else
      Holiday.new(create_params.merge({organisation_id: @organisation.id, is_goverment: false})).save
      render json: {success: true}
    end
  end
    
  private

  def create_params
    params.require(:holiday).permit(:date, :reason, :isMultiDate)
  end

  def update_params
    params.require(:holiday).permit(:date, :reason)
  end
end
