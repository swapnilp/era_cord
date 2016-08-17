class HostelRoomsController < ApplicationController
  before_action :authenticate_user!
 
  #skip_before_filter :authenticate_with_token!, only: [:download_report]
  load_and_authorize_resource param_method: :my_sanitizer
  
  def index
    rooms = HostelRoom.where(hostel_id: params[:hostel_id]).all
    render json: {success: true, rooms: rooms.as_json}
  end

  def edit
    hostel = Hostel.where(id: params[:hostel_id]).first
    return render json: {success: false, message: "Invalid Hostel"} unless hostel.present?
    room = hostel.hostel_rooms.where(id: params[:id]).first
    
    if room.present?
      render json: {success: true, room: room.as_json}
    else
      render json: {success: false, message: "Invalid Hostel Room"}
    end
  end

  def create
    hostel = Hostel.where(id: params[:hostel_id]).first
    return render json: {success: false, message: "Invalid Hostel"} unless hostel.present?
    hostel_room = hostel.hostel_rooms.build(create_params.merge({organisation_id: @organisation.id}))
    if hostel_room.save
      render json: {success: true}
    else
      render json: {success: false, mssage: ""}
    end
  end

  def update
    hostel = Hostel.where(id: params[:hostel_id]).first
    return render json: {success: false, message: "Invalid Hostel"} unless hostel.present?
    room = hostel.hostel_rooms.where(id: params[:id]).first
    
    if room.update_attributes(update_params)
      render json: {success: true}
    else
      render json: {success: false, mssage: ""}
    end
  end
  
  private
  
  def create_params
    params.require(:hostel_room).permit(:name, :beds, :extra_charges)
  end

  def update_params
    params.require(:hostel_room).permit(:name, :beds, :extra_charges)
  end
end
