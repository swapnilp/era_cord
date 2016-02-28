module Users
  class RegistrationsController < Devise::RegistrationsController
    #respond_to :json

    skip_before_filter :authenticate_scope!
    skip_before_filter :authenticate_with_token!, only: [:new, :create, :destroy]

    def new
      if params[:email_code].present?
        @organisation = Organisation.where(email_code: params[:email_code]).first
        raise ActionController::RoutingError.new('Not Found') unless @organisation.present?
      else
        @organisation = nil
      end
      
      build_resource({email: @organisation.try(:email)})
      #set_minimum_password_length
      yield resource if block_given?
      respond_with self.resource
    end
    
    def create
      @organisation = Organisation.where(email_code: params[:email_code]).first
      raise ActionController::RoutingError.new('Not Found') unless @organisation.present?
      #super
      # add custom create logic here
      
      build_resource(sign_up_params.merge({role: params[:user][:role], organisation_id: @organisation.id}))
      
      
      if @organisation.mobile_code == params[:mobile_code]
        resource.save
      else
        resource.errors.add(:mobile_code, "is invalid. Please regenerate code") 
      end
      
      yield resource if block_given?
      if resource.persisted?
        resource.add_organiser_roles if resource.role == 'organisation'
        if resource.active_for_authentication?
          resource.organisation.update_attributes({last_signed_in: Time.now}) if resource.organisation.present?
          set_flash_message :notice, :signed_up if is_flashing_format?
          sign_up(resource_name, resource)
          #respond_with resource, location: after_sign_up_path_for(resource)
          respond_with resource, location: CONSOLE_URL
        else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
          expire_data_after_sign_in!
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        #resource.errors.add(:mobile_code, "is invalid. Please regenerate code") if @organisation.mobile_code != params[:mobile_code]
        respond_with resource
      end
    end
    
    
    def update
      resource = current_user
      if update_resource(resource, account_update_params)
        render json: { success: true, message: 'Password changed successfully' }, status: 200
      else
        clean_up_passwords resource
        render json: { success: false, message: 'Could not update password' }, status: 200 #422 is needed
      end
    end
  end

  protected

  def configure_permitted_parameters
    #devise_parameter_sanitizer.for(:sign_up).push(:email, :role, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :current_password)
  end
end
