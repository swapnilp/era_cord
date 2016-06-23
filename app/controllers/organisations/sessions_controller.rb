module Organisations
  class SessionsController < Devise::SessionsController
    skip_before_filter :authenticate_with_token!, only: [:create, :destroy]
    skip_before_filter :verify_authenticity_token, only: [:create, :destroy]
    skip_before_filter :require_no_authentication, :only => [:create, :cancel ]

    respond_to :json

    def create
      resource = resource_from_credentials
      return invalid_login_attempt unless resource

      if resource.valid_password? params[:organisation][:password]
        render json: resource, success: true, status: :created, serializer: OrganisationLoginSerializer, root: false
      else
        invalid_login_attempt
      end
    end

    def destroy
      begin
        email = JWT.decode(request.headers['Authorization'].split(' ')[1], nil, false)[0]['email']
      rescue NoMethodError
        render json: { message: 'Already logged out.' }, success: true, status: 204
        return
      end

      user = Organisation.find_by email: email
      sign_out user
      user.reset_auth_token!
      render json: { message: 'Logged out successfully.' }, success: true, status: 204
    end

    protected

    def invalid_login_attempt
      warden.custom_failure!
      render json: { success: false, message: 'Invalid email or password.' }, status: 401
    end
 
    def resource_from_credentials
      data = { email: params[:organisation][:email] }
      
      res = resource_class.find_for_database_authentication(data)
      return unless res
      return res if res.valid_password? params[:organisation][:password]
    end
  end
end
