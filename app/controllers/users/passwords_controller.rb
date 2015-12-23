module Users
  class PasswordsController < Devise::PasswordsController
    respond_to :json

    skip_before_filter :authenticate_with_token!

    # Here we don't care if it's actually successful. The reason being
    # if we said that an account didn't exist (for example), that'd be
    # leaking account data. And that would be bad.
    def create
      success = resource_class.send_reset_password_instructions(resource_params)
      if success
        render json: { success: true, message: 'Password reset instructions sent' }, status: 200
      else
        render json: {success: false, message: ""}
      end
    end

    def edit
      @reset_password = ResetPassword.where(token: params[:reset_password_token]).first
      raise ActionController::RoutingError.new('Not Found') unless @reset_password.present?
      
      @organisations = User.where(email: @reset_password.email).map(&:organisation)
      self.resource = resource_class.new
    end

    def update
      #resource = resource_class.reset_password_by_token(resource_params)
      @reset_password = ResetPassword.where(token: params[:reset_password_token]).first

      self.resource = resource_class.where(email: @reset_password.email, organisation_id: params[:organisation_id]).first

      self.resource.reset_password(params[:user][:password], params[:user][:password_confirmation])
      if resource.errors.empty?
        redirect_to CONSOLE_URL
      else
        @organisations = User.where(email: @reset_password.email).map(&:organisation)
        render :edit
      end
    end

    def resource_params
      params.require(:user).permit(:email, :password, :password_confirmation, :token)
    end

    
    private :resource_params
    
  end
end
