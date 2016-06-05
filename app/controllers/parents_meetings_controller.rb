class ParentsMeetingsController < ApplicationController
  before_action :authenticate_user!
  #skip_before_filter :authenticate_with_token!, only: [:download_report]
  load_and_authorize_resource 
  

  def index
    parents_meetings = ParentsMeeting.my_organisation(@organisation.id).order("id desc")
    
    parents_meetings = parents_meetings.page(params[:page])
    render json: {success: true, parents_meetings: parents_meetings.as_json, count: parents_meetings.total_count}
  end

  def create
    parents_meeting = ParentsMeeting.new(create_params.merge({organisation_id: @organisation.id}))
    if parents_meeting.save
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  private

  def create_params
    params.require(:parents_meeting).permit(:agenda, :date, :contact_person)
  end

  

end
