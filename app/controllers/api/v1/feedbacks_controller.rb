class Api::V1::FeedbacksController < ApiController
  skip_before_filter :authenticate_with_token!, only: [:create]

  
  def create
    feedback = FeedBack.new(create_params)
    feedback.medium = "mobile"
    if feedback.save
      render json: {success: true}
    else
      render json: {success: false, message: feedback.errors.full_messages.join(' , ')}
    end
  end

  private 
  
  def create_params
    params.require(:feed_back).permit(:email, :title, :message)
  end
end
