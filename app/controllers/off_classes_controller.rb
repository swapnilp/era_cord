class OffClassesController < ApplicationController
  before_action :authenticate_user!
  before_action :active_standards!, only: [:index, :calender_index]
  
  def index
    off_classes = OffClass.includes([{subject: :standard}, :teacher]).joins(:jkci_class).where("jkci_classes.is_current_active = ? && jkci_classes.standard_id in (?)", true, @active_standards).where(organisation_id: Organisation.current_id)
    if params[:filter].present? &&  JSON.parse(params[:filter])['filterClass'].present?
      off_classes = off_classes.where("jkci_classes.standard_id = ?",JSON.parse(params[:filter])['filterClass'])
    end
    if params[:filter].present? &&  JSON.parse(params[:filter])['filterTeacher'].present?
      off_classes = off_classes.where(teacher_id: JSON.parse(params[:filter])['filterTeacher'])
    end
    off_classes = off_classes.page(params[:page])
    render json: {success: true, off_classes: off_classes.as_json, count: off_classes.total_count}
  end
  
  def calender_index
    off_classes = OffClass.includes(subject: :standard).joins(:jkci_class).where("jkci_classes.is_current_active = ? && jkci_classes.standard_id in (?)", true, @active_standards).where(organisation_id: Organisation.current_id)
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

  def get_filter_data
    teachers = Teacher.select([:first_name, :last_name, :id])
    standards = @organisation.standards.where("organisation_standards.is_active = ?", true)
    render json: {success: true, standards: standards.as_json, teachers: teachers.map(&:filter_json)}
  end
  
end
