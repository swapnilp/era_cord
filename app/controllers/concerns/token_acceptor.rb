module TokenAcceptor
  extend ActiveSupport::Concern

  included do
    before_filter :authenticate_with_token!
  end

  protected

  def authenticate_with_token!
    token = request.headers['Authorization'].presence
    token = params[:authorization_token] unless token

    return reject_token if token.nil?
    
    # Since we're sent 'Bearer <token>', get rid of the 'Bearer' part
    token.gsub!(/\ABearer\s/, '')

    if current_user && current_user.validate_auth_token(token)
      return true 
    end 
    

    return reject_token unless token_valid? token

    # Grab the payload without verifying (yet)
    token_payload, token_header = JWT.decode(token, nil, false)
    # If the token says it's expired, trust it
    return reject_token if token_expired? token_header
    user = User.find_by(email: token_payload['email'], organisation_id: token_payload['organisation_id'])

    if user && user.validate_auth_token(token)
      if current_user && current_user.id == user.id
      else
        sign_in user
      end
    else
      user.clear_token! if user
      reject_token
    end
  end


  def authenticate_org_with_token!
    token = request.headers['Authorization'].presence
    token = params[:authorization_token] unless token

    return reject_token if token.nil?

    if current_organisation && current_organisation.validate_auth_token(token)
      return true 
    end 
    
    # Since we're sent 'Bearer <token>', get rid of the 'Bearer' part
    token.gsub!(/\ABearer\s/, '')

    return reject_token unless token_valid? token

    # Grab the payload without verifying (yet)
    token_payload, token_header = JWT.decode(token, nil, false)
    # If the token says it's expired, trust it
    return reject_token if token_expired? token_header
    
    organisation = Organisation.find_by(email: token_payload['email'])

    if organisation && organisation.validate_auth_token(token)
      
      if current_organisation && current_organisation.id == organisation.id
      else
        sign_in organisation
      end
    else
      reject_token
    end
  end

  def reject_token
    warden.custom_failure!
    render json: { success: false, message: 'Invalid token.' }, status: 401
  end

  def token_expired?(header)
    Time.now.to_i > header['exp']
  end

  def token_valid?(token)
    JWT.decode token, Rails.application.secrets[:secret_key_base]
    true
  rescue JWT::DecodeError
    false
  end
end
