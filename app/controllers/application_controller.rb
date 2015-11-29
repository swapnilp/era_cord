class ApplicationController < ActionController::Base
  include TokenAcceptor
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  skip_before_filter  :verify_authenticity_token
  
  rescue_from CanCan::AccessDenied do |exception|
    render json: { success: false, message: exception.message }, status: 403
  end
  
  def authenticate_user!(options={})
    super(options)
    @organisation ||= current_user.organisation
    Organisation.current_id = @organisation.present? ? @organisation.subtree.map(&:id) : nil
    #@organisation.update_attributes({last_signed_in: Time.now}) if @organisation.present?
  end

  def render_422(object, message, opts = {})
    render opts.merge(json: { success: false, message: message, errors: object.errors.full_messages }, status: 422)
  end
end
