class ApplicationController < ActionController::Base
  include TokenAcceptor
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def render_422(object, message, opts = {})
    render opts.merge(json: { success: false, message: message, errors: object.errors.full_messages }, status: 422)
  end
end
