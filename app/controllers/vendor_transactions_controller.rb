class VendorTransactionsController < ApplicationController
  before_action :authenticate_user!, except: [:sync_organisation_students]
  
  load_and_authorize_resource

  before_action :find_vendor
  
  #skip_before_filter :authenticate_with_token!, only: [:download_report]
  #load_and_authorize_resource param_method: :my_sanitizer, except: [:sync_organisation_students]
  
  def index
    vendor_transactions = @vendor.vendor_transactions.all
    vendor_transactions = vendor_transactions.page(params[:page])
    render json: {success: true, vendor_transactions: vendor_transactions.as_json, total_count: vendor_transactions.total_count}
  end

  def new

  end
  
  def create
    #Date.strptime("01/01/2017", "%d/%m/%Y")
    vendor_transaction = @vendor.vendor_transactions.new(create_params)
    if vendor_transaction.save
      render json: {success: true}
    else
      render json: {success: false, message: vendor_transaction.errors.full_messages.join(' , ')}
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

  def find_vendor
    @vendor = Vendor.where(id: params[:vendor_id]).first
    return render json: {success: false,  message: "Invalid vendor"} unless @vendor.present?
  end
  
  def create_params
    params.require(:vendor_transaction).permit(:type, :amount, :cheque_number, :issue_date, :transaction_type)
  end

  def update_params
    params.require(:vendor_transaction).permit(:type, :amount, :cheque_number, :issue_date, :transaction_type)
  end

end
