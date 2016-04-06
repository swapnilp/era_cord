module Users
  #class InvitationsController < Devise::InvitationsController
  #  respond_to :json
  #
  #  skip_before_filter :authenticate_with_token!
  #
  #  def update
  #    resource = accept_resource
  #
  #    if resource.errors.empty?
  #      render json: { success: true, message: 'Your password has been set. You can now log in to Centaur.' }, status: 200
  #    else
  #      render json: { success: false, message: resource.errors.full_messages.join('. ') }, status: 422
  #    end
  #  end
  #end
end
