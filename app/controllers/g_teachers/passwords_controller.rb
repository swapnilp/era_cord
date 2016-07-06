module GTeachers
  class PasswordsController < Devise::PasswordsController
    #respond_to :json

    skip_before_filter :authenticate_scope!
    skip_before_filter :authenticate_with_token!#, only: [:new, :create, :update, :destroy]
    
    # Here we don't care if it's actually successful. The reason being
    # if we said that an account didn't exist (for example), that'd be
    # leaking account data. And that would be bad.

     def new
       self.resource = resource_class.new
     end
     
    def create
      success = resource_class.send_reset_password_instructions(resource_params)
      if success
        respond_to do |format|
          flash[:notice] = "Password successfully sent to your email. Please check your Email"
          format.html { redirect_to(root_url)}
          format.json { render json: { success: true, message: 'Password reset instructions sent' }, status: 200}
        end
      else

        self.resource = resource_class.new
        self.resource.errors.add(:email, "Email id not present")
        render :new
      end
    end

    def edit
      @reset_password = ResetPassword.where(token: params[:reset_password_token], object_type: "Teacher").first
      raise ActionController::RoutingError.new('Not Found') unless @reset_password.present?
      
      self.resource = resource_class.new
    end

    def update
      #resource = resource_class.reset_password_by_token(resource_params)
      @reset_password = ResetPassword.where(token: params[:reset_password_token], object_type: "Teacher").first

      self.resource = resource_class.where(email: @reset_password.email).first

      self.resource.reset_password(params[:g_teacher][:password], params[:g_teacher][:password_confirmation])
      if resource.errors.empty?
        @reset_password.destroy
        flash[:notice] = "Password change successfully. Please Login from your devise."
        redirect_to root_url
      else
        render :edit
      end
    end

    def resource_params
      params.require(:g_teacher).permit(:email, :token)
    end

    
    private :resource_params
    
  end
end
