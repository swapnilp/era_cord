class SmsSentController < ApplicationController
  
  before_action :authenticate_user!
  #skip_before_filter :authenticate_with_token!, only: [:download_report]
  load_and_authorize_resource param_method: :my_sanitizer
  

  def index
    sms_sents = SmsSent.our_organisations.my_organisation(@organisation.id).order("id desc").page(params[:page])
    render json: {success: true, sms_sents: sms_sents.as_json, count: sms_sents.total_count}
  end
  
end
