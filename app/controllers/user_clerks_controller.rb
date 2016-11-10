class UserClerksController < ApplicationController
  before_action :authenticate_user!
  
  def edit
    user_clerk = @organisation.user_clerks.where(id: params[:id]).first
    if user_clerk.present?
      render json: {success: true, data: user_clerk.as_json}
    else
      render json: {success: false, message: "Something went wrong"}
    end
  end

  def update
    user_clerk = @organisation.user_clerks.where(id: params[:id]).first
    if user_clerk.present?
      if update_params[:mobile] != user_clerk.mobile
        user_clerk.resend_sms
      end
      user_clerk.update_attributes(update_params)
      render json: {success: true}
    else
      render json: {success: false, message: "Something went wrong"}
    end
  end
  
  def destroy
    user_clerks = @organisation.user_clerks.where(id: params[:id]).first
    if user_clerks && user_clerks.destroy
      render json: {success: true}
    else
      render json: {success: false, message: "Something went wrong"}
    end
  end

  def resend_invitation
    user_clerk = @organisation.user_clerks.where(id: params[:id]).first
    if user_clerk.present?
      user_clerk.resend_invitation
      render json: {success: true}
    else
      render json: {success: false, message: "Something went wrong"}
    end
  end

  
  def update_params
    params.require(:clerk).permit(:mobile)
  end
end
