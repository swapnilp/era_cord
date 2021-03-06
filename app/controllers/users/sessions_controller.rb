module Users
  class SessionsController < Devise::SessionsController
    skip_before_filter :authenticate_with_token!, only: [:new, :create, :mobile_login,:mpin_login, :get_organisations, :destroy]
    skip_before_filter :verify_authenticity_token, only: [:new, :create, :mobile_login, :mpin_login, :get_organisations, :destroy]
    skip_before_filter :require_no_authentication, :only => [ :new, :create, :mobile_login, :mpin_login, :get_organisations, :cancel]

    respond_to :json

    def create
      return invalid_login_attempt unless params[:user].present?
      unless params[:user][:organisation_id].present?
        duplicates = resource_from_credentials_check_duplicates || []
        
        if duplicates.count > 1
          return render json: {success: false, email: params[:user][:email], organisations: duplicates.map(&:organisation_json)}
        end
      end
      resource = resource_from_credentials

      return invalid_login_attempt unless resource
      if resource.valid_password? params[:user][:password]
        
        resource.set_last_sign_in_at
        render json: resource, success: true, status: :created, serializer: UserLoginSerializer, root: false
      else
        invalid_login_attempt
      end
    end

    def mobile_login
      return invalid_login_attempt unless params[:user].present?
      resource = resource_from_credentials

      return invalid_login_attempt unless resource
      if resource.valid_password? params[:user][:password]
        render json: resource, success: true, status: :created, serializer: UserMobileLoginSerializer, root: false
      else
        invalid_login_attempt
      end
    end

    def get_organisations
      return invalid_login_attempt unless params[:email].present? && params[:device_id].present?
      duplicates = resource_from_mobile_credentials_check_duplicates || []
      if duplicates.count > 0
        return render json: {success: true, email: params[:email], organisations: duplicates.map(&:organisation_json), multiple_organisations: duplicates.count > 1}
      else
        return render json: {success: false, message: "Invalide"}
      end
    end
    
    def mpin_login
      return invalid_login_attempt unless params[:user].present?
      resource = resource_from_mobile_credentials

      return invalid_login_attempt unless resource
      
      if resource.mpin == params[:user][:mpin].to_i && resource.has_role?(:teacher)
        render json: resource, success: true, status: :created, serializer: UserMobileLoginSerializer, root: false
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

      user = User.find_by email: email
      user.clear_token!
      sign_out user
      #user.reset_auth_token!
      render json: { message: 'Logged out successfully.' }, success: true, status: 204
    end

    protected

    def invalid_login_attempt
      warden.custom_failure!
      render json: { success: false, message: 'Invalid email or password.' }, status: 401
    end

    def resource_from_credentials_check_duplicates
      data = { email: params[:user][:email] }
      resource_class.check_duplicate(data, params[:user][:password])      
    end

    def resource_from_mobile_credentials_check_duplicates
      data = { email: params[:email], device_id: params[:device_id] }
      resource_class.get_teachers_organisations(data)
    end

    def resource_from_credentials
      data = { email: params[:user][:email] }
      if params[:user][:organisation_id].present?
        data = data.merge({organisation_id: params[:user][:organisation_id]})
      end
      
      res = resource_class.find_for_database_authentication(data)

      if res.count > 1
        res = res.select{|u| u.valid_password? params[:user][:password]}.first
      else
        res = res[0]
      end
      return unless res
      return res if res.valid_password? params[:user][:password]
    end

    def resource_from_mobile_credentials
      data = { email: params[:user][:email], device_id: params[:user][:device_id] }
      if params[:user][:organisation_id].present?
        data = data.merge({organisation_id: params[:user][:organisation_id]})
      end

      res = resource_class.find_teacher_for_database_authentication(data)
      if res.count > 1
        res = res.first
      else
        res = res[0]
      end
      return unless res
      return res if res.mpin == params[:user][:mpin].to_i
    end
  end
end
