class RegisterOrganisationsController < ApplicationController
  skip_before_filter :authenticate_with_token!, only: [:new, :create, :destroy, :sms_confirmation, :verify_confirmation]
  skip_before_filter :verify_authenticity_token, only: [:new, :create, :destroy, :sms_confirmation, :verify_confirmation]
  skip_before_filter :require_no_authentication, :only => [ :new, :create, :cancel, :sms_confirmation, :verify_confirmation ]
  http_basic_authenticate_with name: ORG_CREATE_U_NAME, password: ORG_CREATE_U_PASSWORD
  
  def new
    @register_organisation = TemporaryOrganisation.new
  end
  
  def create
    @register_organisation = TemporaryOrganisation.new(create_params.slice(:name, :email, :mobile, :short_name, :user_email))
    user = User.where(email: create_params[:user_email]).first 
    if user && user.valid_password?(params[:temporary_organisation][:password])
      if user.has_role? :creator
        if @register_organisation.save
          @register_organisation.generate_code(user)
          redirect_to sms_confirmation_register_organisation_path(@register_organisation.id_hash)
        else
          
          render :new
        end
      else
        flash[:notice] = "You are not authorised for add Organisation"
        redirect_to root_url
      end
    else
      render :new
    end
  end

  def sms_confirmation
    @register_organisation = TemporaryOrganisation.where(id_hash: params[:id]).first
    if @register_organisation.present? && !@register_organisation.is_confirmed
      
    else
      flash[:notice] = "Something went wrong please contact admin."
      redirect_to root_url
    end
  end

  def verify_confirmation
    @register_organisation = TemporaryOrganisation.where(id_hash: params[:id]).first
    if @register_organisation && @register_organisation.user_sms_code == params[:temporary_organisation][:sms_code] 
      @register_organisation.create_organisation if !@register_organisation.is_confirmed
      flash[:notice] = "Successfully verified. Please check client's Email"
      redirect_to root_url
    else
      @register_organisation.errors.add(:sms_code, " must match.")
      render :sms_confirmation
    end
  end
  
  protected
  def create_params
    params.require(:temporary_organisation).permit(:name, :email, :mobile, :short_name, :user_email, :password)
  end
end
