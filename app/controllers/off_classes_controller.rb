class OffClassesController < ApplicationController
  before_action :authenticate_user!
  
  def index
  end
  
  def calender_index
    off_classes = OffClass.includes(subject: :standard).joins(:jkci_class).where("jkci_classes.is_current_active = ? ", true).where(organisation_id: Organisation.current_id)
    if params[:start]
      off_classes = off_classes.where("date >= ? ", Date.parse(params[:start]))
    end
    if params[:end]
      off_classes = off_classes.where("date <= ? ", Date.parse(params[:end]))
    end

    if params[:standard]
      off_classes = off_classes.where("jkci_classes.standard_id = ? ",  params[:standard])
    end
    
    render json: {success: true, off_classes: off_classes.map(&:calendar_json)}
  end
  
end
