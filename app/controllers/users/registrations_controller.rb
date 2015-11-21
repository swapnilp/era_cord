module Users
  class RegistrationsController < Devise::RegistrationsController
    respond_to :json

    skip_before_filter :authenticate_scope!

    def update
      resource = current_user
      if update_resource(resource, account_update_params)
        render json: { success: true, message: 'Password changed successfully' }, status: 200
      else
        clean_up_passwords resource
        render json: { success: false, message: 'Could not update password' }, status: 422
      end
    end
  end
end
