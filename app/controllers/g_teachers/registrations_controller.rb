module GTeachers
  class RegistrationsController < Devise::RegistrationsController
    #respond_to :json
    skip_before_filter :authenticate_scope!
    skip_before_filter :authenticate_with_token!, only: [:new, :create, :update, :destroy]

    def new
      if params[:email_token].present?
        g_teacher = GTeacher.where(email_code: params[:email_token]).first
        raise ActionController::RoutingError.new('Not Found') unless g_teacher.present?
      else
        raise ActionController::RoutingError.new('Not Found')
      end
      
      build_resource(g_teacher.attributes)

      #set_minimum_password_length
      yield resource if block_given?
      respond_with self.resource
    end
    
    def create
      update_teachers
    end
    
    
    def update
      update_teachers
    end
    
    def update_teachers
      if params[:email_token].present?
        g_teacher = GTeacher.where(email_code: params[:email_token]).first
        raise ActionController::RoutingError.new('Not Found') unless g_teacher.present?
      else
        raise ActionController::RoutingError.new('Not Found')
      end
      
      #build_resource(g_teacher.attributes)
      self.resource = g_teacher
      
      if params[:mobile_code] == resource.mobile_code 
        if resource.update_attributes(account_update_params)
          resource.update_attributes({mobile_code: "", email_code: ""})
          flash[:notice] = "Successfully Created. Please check email for notifications"
          redirect_to root_url
        else
          clean_up_passwords resource
          p resource.errors
          render :new #json: { success: false, message: 'Could not update password' }, status: 200 #422 is needed
        end
      else
        render :new #xjson: { success: false, message: '' }, status: 200 #422 is needed
      end
    end
  end
  
  protected

  def configure_permitted_parameters
    #devise_parameter_sanitizer.for(:sign_up).push(:password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :current_password)
  end
end
