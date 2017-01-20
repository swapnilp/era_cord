class HolidaysController < ApplicationController
  before_action :authenticate_user!
 
  #skip_before_filter :authenticate_with_token!, only: [:download_report]
  load_and_authorize_resource param_method: :my_sanitizer
  
  def index
    holidays = Holiday.current
    
    if params[:filter].present? &&  JSON.parse(params[:filter])['dateRange'].present? && JSON.parse(params[:filter])['dateRange']['startDate'].present?
      holidays = holidays.where("date >= ?", JSON.parse(params[:filter])['dateRange']['startDate'].to_time)
    end
    if params[:filter].present? &&  JSON.parse(params[:filter])['dateRange'].present? && JSON.parse(params[:filter])['dateRange']['endDate'].present?
      holidays = holidays.where("date <= ?", JSON.parse(params[:filter])['dateRange']['endDate'].to_time)
    end

    if params[:filter].present? && JSON.parse(params[:filter])['type'].present?
    else
      holidays = holidays.upcomming
    end
    holidays = holidays.order("date asc").page(params[:page])
    
    render json: {success: true, holidays: holidays.as_json, total_count: holidays.total_count}
  end
  
  def create
    return render json: {success: false, message: "Must be root user"} unless @organisation.root?
    
    if create_params[:isMultiDate]
      (JSON.parse(params['dateRange'])['startDate'].to_time.to_date..JSON.parse(params['dateRange'])['endDate'].to_time.to_date ).to_a.each do |date| 
        
        holiday = Holiday.new({date: date, reason: create_params[:reason], organisation_id: @organisation.id, is_goverment: false})
        unless create_params[:allOrganisation]
          holiday.classes = ",#{create_params[:classList]},"  
          holiday.specific_class = true
        end
        holiday.save
      end
      render json: {success: true}
    else
      holiday = Holiday.new(create_params.merge({organisation_id: @organisation.id, is_goverment: false}))
      unless create_params[:allOrganisation]
        holiday.classes = ",#{create_params[:classList]},"  
        holiday.specific_class = true
      end
      holiday.save
      render json: {success: true}
    end
  end

  def destroy
    return render json: {success: false, message: "Must be root user"} unless @organisation.root?
    holiday = Holiday.where(id: params[:id]).first
    if holiday && holiday.destroy
      render json: {success: true}
    else
      render json: {success: false, message: "Something went wrong"}
    end
  end

  def get_classes
    classes = @organisation.jkci_classes.active
    render json: {success: true, classes: classes.map(&:sync_json)}
  end
    
  private

  def create_params
    params.require(:holiday).permit(:date, :reason, :isMultiDate, :classList, :allOrganisation)
  end

  def update_params
    params.require(:holiday).permit(:date, :reason)
  end
end
