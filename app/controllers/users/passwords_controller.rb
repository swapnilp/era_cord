module Users
  class PasswordsController < Devise::PasswordsController
    respond_to :json

    skip_before_filter :authenticate_with_token!

    # Here we don't care if it's actually successful. The reason being
    # if we said that an account didn't exist (for example), that'd be
    # leaking account data. And that would be bad.
    def create
      resource_class.send_reset_password_instructions(resource_params)
      render json: { success: true, message: 'Password reset instructions sent' }, status: 200
    end

    def update
      resource = resource_class.reset_password_by_token(resource_params)

      if resource.errors.empty?
        render json: { success: true, message: 'Your password has been reset. You may use your new password to log in.' }, status: 200
      else
        render json: { success: false, message: resource.errors.full_messages.join('. ') }, status: 422
      end
    end
  end
end
