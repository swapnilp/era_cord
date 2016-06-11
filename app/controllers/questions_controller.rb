class QuestionsController < ApplicationController
  skip_before_filter :authenticate_with_token!
  skip_before_filter :verify_authenticity_token
  skip_before_filter :require_no_authentication
  def index
    questions = Question.all
    render json: {success: true, questions: questions.as_json}
  end

  def show
    question = Question.where(id: params[:id]).first
    if question
      render json: {success: true, question: question.as_json, answers: question.answers.as_json}
    else
      render json: {success: false}
    end
    
  end
end
