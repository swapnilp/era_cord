class ApplicationController < ActionController::Base
  include TokenAcceptor
  #include LocalSubdomain
  include UrlHelper

  
  Range.include CoreExtensions::Range

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  skip_before_filter  :verify_authenticity_token

  before_action :configure_permitted_parameters, if: :devise_controller?
  after_filter :set_access_control_headers

  
  rescue_from CanCan::AccessDenied do |exception|
    
    render json: { success: false, message: exception.message }, status: 403
  end
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  
  def authenticate_user!(options={})
    super(options)
    validate_rpm
    @organisation = current_user.organisation
    Organisation.current_id = @organisation.present? ? @organisation.root.subtree.map(&:id) : nil
    #@organisation.update_attributes({last_signed_in: Time.now}) if @organisation.present?
  end
  
  def validate_rpm

    if ApiRpmStore.threshold?(current_user.id.to_s, current_user.request_per_min) # request_per_min is  threshold for
      render json: {message: 'too_many_requests'}, status: :too_many_requests
      return false
    end
  end

  def set_access_control_headers
    return unless Rails.env.development? # important! we don't want to set it in production, since we already did on nginx
    headers['access-control-allow-origin'] = '*'
  end

  def authenticate_organisation!(options={})
    super(options)
    @organisation ||= current_organisation
    Organisation.current_id = @organisation.present? ? @organisation.root.subtree.map(&:id) : nil
    #@organisation.update_attributes({last_signed_in: Time.now}) if @organisation.present?
  end

  def active_standards!
    @active_standards ||= []
    if @organisation.present? && @active_standards.blank?
      @active_standards = @organisation.root.organisation_standards.active.map(&:standard_id)
    end
  end

  def render_422(object, message, opts = {})
    render opts.merge(json: { success: false, message: message, errors: object.errors.full_messages }, status: 422)
  end

  def record_not_found(error)
    render :json => {success: false, :error => error.message}, :status => :not_found
  end 

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :password, :remember_me, :organisation_id) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:password, :password_confirmation, :current_password)}
    devise_parameter_sanitizer.for(:reset_password) { |u| u.permit(:email)}
  end
end
