module Users
  class RegistrationsController < Devise::RegistrationsController
    #respond_to :json

    skip_before_filter :authenticate_scope!
    skip_before_filter :authenticate_with_token!, only: [:new, :create, :destroy]

    def new
      if params[:email_token].present?
        @organisation = Organisation.where(email_code: params[:email_token]).first
        @g_teacher = GTeacher.where(email_code: params[:email_token]).first
        @user_clerk = UserClerk.where(email_token: params[:email_token]).first
        raise ActionController::RoutingError.new('Not Found') unless @organisation.present? || @g_teacher.present? || @user_clerk.present?
      else
        raise ActionController::RoutingError.new('Not Found') unless @organisation.present?
      end
      
      if @organisation.present?
        build_resource({email: @organisation.try(:email)}) 
      elsif @g_teacher
        build_resource({email: @g_teacher.try(:email)}) 
      else 
        build_resource({email: @user_clerk.try(:email)}) 
      end
      
      #set_minimum_password_length
      yield resource if block_given?
      respond_with self.resource
    end
    
    def create
      @organisation = Organisation.where(email_code: params[:email_token]).first
      @g_teacher = GTeacher.where(email_code: params[:email_token]).first
      @user_clerk = UserClerk.where(email_token: params[:email_token]).first
      raise ActionController::RoutingError.new('Not Found') unless @organisation.present? || @g_teacher.present? || @user_clerk.present?
      #super
      # add custom create logic here
      
      if @g_teacher.present?
        @organisation = Teacher.unscoped.where(g_teacher_id: @g_teacher.id).first.organisation
        mobile_code = @g_teacher.mobile_code
      elsif @organisation.present?
        mobile_code = @organisation.mobile_code
      elsif @user_clerk.present?
        mobile_code = @user_clerk.mobile_token
        @organisation = @user_clerk.organisation
      end
      
      build_resource(sign_up_params.merge({role: params[:user][:role], organisation_id: @organisation.id}))

      if mobile_code == params[:mobile_code]
        resource.verify_mobile = true
        resource.save
        if @user_clerk.present?
          resource.add_clerk_roles
          @user_clerk.destroy 
        end
      else
        resource.errors.add(:mobile_code, "is invalid. Please regenerate code") 
      end
      
      yield resource if block_given?
      if resource.persisted?
        if resource.role == 'organisation'
          resource.add_organiser_roles 
        elsif resource.role == 'teacher'
          resource.add_teacher_roles
        end
        if @g_teacher.present?
          @g_teacher.update_attributes({email_code: nil, mobile_code: nil})
        else
          @organisation.update_attributes({email_code: nil, mobile_code: nil})
        end
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

    def create_mpin
      resource = current_user
      if params[:user].present? && params[:user][:device_id] && params[:user][:mpin]
        User.where(email: resource.email).update_all({device_id: params[:user][:device_id], mpin: params[:user][:mpin]})
        duplicates = User.where(device_id: resource.device_id, email: resource.email) || []
        render json: { success: true, message: 'mPin update successfully', organisations: duplicates.map(&:organisation_json), multiple_organisations: duplicates.count > 1 }, status: 200
      else
        render json: { success: false, message: 'mPin not generated' }, status: 200
      end
    end

    def update
      resource = current_user
      success = true
      User.where(email: current_user.email).each do |user|
        resource = user
        success = update_resource(resource, account_update_params)
        break unless success 
      end
      if success 
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
