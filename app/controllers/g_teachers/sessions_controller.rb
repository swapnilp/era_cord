module GTeachers
  class SessionsController < Devise::SessionsController
    skip_before_filter :authenticate_with_token!, only: [:new, :create, :destroy]
    skip_before_filter :verify_authenticity_token, only: [:new, :create, :destroy]
    skip_before_filter :require_no_authentication, :only => [:new, :create, :cancel ]
    skip_before_action :verify_authenticity_token, :only => [:new, :create, :cancel ]

    respond_to :json

    def create
      resource = resource_from_credentials
      return invalid_login_attempt unless resource
      
      if resource.valid_password? params[:g_teacher][:password]
        teachers = Teacher.unscoped.where(g_teacher_id: resource.id)
        if teachers.count > 1
          render json: resource, success: true, status: :created, organisations: []
        else
          render json: resource, success: true, status: :created, serializer: GTeacherLoginSerializer
        end
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

      g_teacher = GTeacher.find_by email: email
      sign_out g_teacher
      g_teacher.reset_auth_token!
      render json: { message: 'Logged out successfully.' }, success: true, status: 204
    end

    protected

    def invalid_login_attempt
      warden.custom_failure!
      render json: { success: false, message: 'Invalid email or password.' }, status: 401
    end
 
    def resource_from_credentials
      data = { email: params[:g_teacher][:email] }
      
      res = resource_class.find_for_database_authentication(data)
      return unless res
      return res if res.valid_password? params[:g_teacher][:password]
    end
  end
end
