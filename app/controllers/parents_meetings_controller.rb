class ParentsMeetingsController < ApplicationController
  before_action :authenticate_user!
  #skip_before_filter :authenticate_with_token!, only: [:download_report]
  load_and_authorize_resource 
  

  def index
    parents_meetings = ParentsMeeting.my_organisation(@organisation.id).order("id desc")
    
    parents_meetings = parents_meetings.page(params[:page])
    render json: {success: true, parents_meetings: parents_meetings.as_json, count: parents_meetings.total_count}
  end

  def new
    jkci_classes = JkciClass.active
    render json: {success: true, classes: jkci_classes.map(&:meeting_json)}
  end

  def create
    parents_meeting = ParentsMeeting.new(create_params.merge({organisation_id: @organisation.id}))
    if parents_meeting.save
      parents_meeting.create_meetings_students(@organisation.root, params[:student_list])
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def show
    parents_meeting = ParentsMeeting.where(id: params[:id]).first
    if parents_meeting.present?
      render json: {success: true, parents_meeting: parents_meeting.as_json}
    else
      render json: {success: false}
    end
  end

  def get_class_students
    jkci_class = JkciClass.where(id: params[:class_id]).first
    if jkci_class.present?
      class_students = ClassStudent.includes(:student).where(jkci_class_id: params[:class_id])
      render json: {success: true, students: class_students.map(&:meetings_json)}
    else
      render json: {success: false}
    end
  end

  private

  def create_params
    params.require(:parents_meeting).permit(:agenda, :date, :contact_person)
  end

  

end
