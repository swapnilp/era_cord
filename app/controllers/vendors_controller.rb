class VendorsController < ApplicationController
  before_action :authenticate_user!, except: [:sync_organisation_students]
  
  load_and_authorize_resource
  
  #skip_before_filter :authenticate_with_token!, only: [:download_report]
  #load_and_authorize_resource param_method: :my_sanitizer, except: [:sync_organisation_students]
  
  def index
    vendors = Vendor.all
    vendors = vendors.page(params[:page])
    render json: {success: true, vendors: vendors.as_json, total_count: vendors.total_count}
  end

  def new

  end
  
  def create
    vendor = Vendor.new(create_params)
    if vendor.save
      render json: {success: true}
    else
      render json: {success: false, message: vendor.errors.full_messages.join(' , ')}
    end
  end
  
  def show
    vendor = Vendor.where(id: params[:id]).first
    if vendor.present?
      render json: {success: true, vendor: vendor.as_json}
    else
      render json: {success: false}
    end
  end

  def edit

  end

  def update
    
  end
  
    
  private
  
  def create_params
    params.require(:vendor).permit(:name, :nick_name, :cheque_name, :ac_no, :bank, :address, :reason, :mobile)
  end

  def update_params
    params.require(:vendor).permit(:name, :nick_name, :cheque_name, :ac_no, :bank, :address, :reason, :mobile)
  end

end
