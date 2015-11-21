module Users
  class UnlocksController < Devise::UnlocksController
    respond_to :json

    skip_before_filter :authenticate_with_token!

    def create
      resource = resource_class.send_unlock_instructions(resource_params)

      if successfully_sent? resource
        render json: { success: true, message: 'Account unlock instructions sent' }, status: 200
      else
        render json: { success: false, message: resource.errors.full_messages.join('. ') }, status: 422
      end
    end

    def show
      resource = resource_class.unlock_access_by_token(params[:unlock_token])

      if resource.errors.empty?
        render json: { success: true, message: 'Your account has been unlocked. Please sign in to continue.' }, status: 200
      else
        render json: { success: false, message: resource.errors.full_messages.join('. ') }, status: 422
      end
    end
  end
end
