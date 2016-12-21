class SmsSentController < ApplicationController
  
  before_action :authenticate_user!
  #skip_before_filter :authenticate_with_token!, only: [:download_report]
  load_and_authorize_resource 
  

  def index
    sms_sents = SmsSent.our_organisations.my_organisation(@organisation.id).order("id desc")
    if params[:filter].present? &&  JSON.parse(params[:filter])['student'].present?
      sms_sents = sms_sents.where("number like ?", "%#{JSON.parse(params[:filter])['student']}%")
    end

    if params[:filter].present? &&  JSON.parse(params[:filter])['dateRange'].present? && JSON.parse(params[:filter])['dateRange']['startDate'].present?
      sms_sents = sms_sents.where("created_at >= ? ", JSON.parse(params[:filter])['dateRange']['startDate'])
    end

    if params[:filter].present? &&  JSON.parse(params[:filter])['dateRange'].present? && JSON.parse(params[:filter])['dateRange']['endDate'].present?
      sms_sents = sms_sents.where("created_at <= ? ", JSON.parse(params[:filter])['dateRange']['endDate'])
    end
    
    sms_sents = sms_sents.page(params[:page])
    render json: {success: true, sms_sents: sms_sents.as_json, count: sms_sents.total_count}
  end

  
end
