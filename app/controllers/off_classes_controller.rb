class OffClassesController < ApplicationController
  before_action :authenticate_user!
  
  def index
  end
  
  def calender_index
    off_classes = @organisation.off_classes.includes(subject: :standard)
    render json: {success: true, off_classes: off_classes.map(&:calendar_json)}
  end
  
end
