class VendorsController < ApplicationController
  before_action :authenticate_user!, except: [:sync_organisation_students]
  
  load_and_authorize_resource
  
  #skip_before_filter :authenticate_with_token!, only: [:download_report]
  #load_and_authorize_resource param_method: :my_sanitizer, except: [:sync_organisation_students]
  
  def index
    vendors = Vendor.all.order("id desc")
    if params[:filter].present? &&  JSON.parse(params[:filter])['name'].present?
      query = "%#{JSON.parse(params[:filter])['name']}%"
      vendors = vendors.where("name LIKE ? || nick_name LIKE ? || mobile like ?", query, query, query)
    end
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
    vendor = Vendor.where(id: params[:id]).first
    if vendor.present?
      render json: {success: true, vendor: vendor.as_json}
    else
      render json: {success: false}
    end
  end

  def update
    vendor = Vendor.where(id: params[:id]).first
    if vendor.present?
      vendor.update(update_params)
      render json: {success: true, vendor_id: vendor.id}
    else
      render json: {success: false}
    end
  end

  def get_logs
    logs = VendorTransaction.includes(:vendor).all

    if params[:filter].present? &&  JSON.parse(params[:filter])['dateRange'] && JSON.parse(params[:filter])['dateRange']['startDate'].present?
      logs = logs.where("created_at >= ? ", JSON.parse(params[:filter])['dateRange']['startDate'].to_date)
    end

    if params[:filter].present? &&  JSON.parse(params[:filter])['dateRange'] && JSON.parse(params[:filter])['dateRange']['endDate'].present?
      logs = logs.where("created_at <= ? ", JSON.parse(params[:filter])['dateRange']['endDate'].to_date)
    end
    
    logs = logs.page(params[:page])
    
    render json: {success: true, logs: logs.map(&:logs_json), total_logs: logs.total_count}
  end
  
    
  private
  
  def create_params
    params.require(:vendor).permit(:name, :nick_name, :cheque_name, :ac_no, :bank, :address, :reason, :mobile)
  end

  def update_params
    params.require(:vendor).permit(:nick_name, :cheque_name, :ac_no, :bank, :address, :reason, :mobile)
  end

end
