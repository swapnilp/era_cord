class QuestionsController < ApplicationController
  skip_before_filter :authenticate_with_token!
  skip_before_filter :verify_authenticity_token
  skip_before_filter :require_no_authentication
  
  def index
    
    questions = Question.where(filter_query)
    render json: {success: true, questions: questions.as_json}
  end
  
  def filter_info
    tags = Question.select(:tag).uniq.map(&:tag)
    render json: {success: true, tags: tags}
  end

  def show
    question = Question.where(id: params[:id]).first
    if question
      render json: {success: true, question: question.as_json, answers: question.answers.as_json}
    else
      render json: {success: false}
    end
  end

  protected

  def filter_query
    params[:keys].split(",").map{|a, str = ""| "tag like '%#{a}%'"  }.join(" || ")
  end
end
