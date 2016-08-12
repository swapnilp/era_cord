class HostelsController < ApplicationController
  before_action :authenticate_user!
 
  #skip_before_filter :authenticate_with_token!, only: [:download_report]
  load_and_authorize_resource param_method: :my_sanitizer
  
  def index
    hostels = Hostel.all
    
    render json: {success: true, hostels: []}
  end
end
