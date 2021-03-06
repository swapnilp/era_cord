class HostelRoomsController < ApplicationController
  before_action :authenticate_user!
 
  #skip_before_filter :authenticate_with_token!, only: [:download_report]
  load_and_authorize_resource param_method: :my_sanitizer
  
  def index
    return render json: {success: false, message: "Must be root user"} unless @organisation.root?
    
    hostel = Hostel.where(id: params[:hostel_id]).first
    return render json: {success: false, message: "Invalid Hostel"} unless hostel.present?
    rooms = hostel.hostel_rooms.includes(:students)
    render json: {success: true, rooms: rooms.as_json, unallocated_students: hostel.students.unoccupied_students.count}
  end

  def edit
    return render json: {success: false, message: "Must be root user"} unless @organisation.root?
    
    hostel = Hostel.where(id: params[:hostel_id]).first
    return render json: {success: false, message: "Invalid Hostel"} unless hostel.present?
    room = hostel.hostel_rooms.where(id: params[:id]).first
    
    if room.present?
      render json: {success: true, room: room.as_json, students_count: room.students_count}
    else
      render json: {success: false, message: "Invalid Hostel Room"}
    end
  end

  def create
    return render json: {success: false, message: "Must be root user"} unless @organisation.root?
    
    hostel = Hostel.where(id: params[:hostel_id]).first
    return render json: {success: false, message: "Invalid Hostel"} unless hostel.present?
    return render json: {success: false, message: "Room limits are full"} if hostel.hostel_rooms.count >= hostel.rooms
    
    hostel_room = hostel.hostel_rooms.build(create_params.merge({organisation_id: @organisation.id}))
    if hostel_room.save
      hostel_room.add_log_new_room
      render json: {success: true}
    else
      render json: {success: false, mssage: ""}
    end
  end

  def update
    return render json: {success: false, message: "Must be root user"} unless @organisation.root?
    
    hostel = Hostel.where(id: params[:hostel_id]).first
    return render json: {success: false, message: "Invalid Hostel"} unless hostel.present?
    room = hostel.hostel_rooms.where(id: params[:id]).first
    
    if room.update_attributes(update_params)
      room.add_log_edit_room
      render json: {success: true}
    else
      render json: {success: false, mssage: ""}
    end
  end

  def allocate_students
    return render json: {success: false, message: "Must be root user"} unless @organisation.root?
    
    hostel = Hostel.where(id: params[:hostel_id]).first
    room = hostel.hostel_rooms.where(id: params[:id]).first
    return render json: {success: false, message: "Invalid Hostel or Room"} unless hostel.present? || room.present?

    student_ids = (params[:student_ids] || "").split(',').map(&:to_i)
    if room && (student_ids.count > 0) && (room.remaining_beds >= student_ids.count)
      students = hostel.students.where(id: student_ids)
      room.students << students
      students.map(&:hostel_log_allocate_room)
      render json: {success: true}
    else
      render json: {success: false, mssage: "Invalid Students"}
    end
  end

  def destroy
    return render json: {success: false, message: "Must be root user"} unless @organisation.root?
    
    hostel = Hostel.where(id: params[:hostel_id]).first
    room = hostel.hostel_rooms.where(id: params[:id]).first
    return render json: {success: false, message: "Invalid Hostel or Room"} unless hostel.present? || room.present?
    
    room.delete_room
    render json: {success: true}
  end
  
  private
  
  def create_params
    params.require(:hostel_room).permit(:name, :beds, :extra_charges)
  end

  def update_params
    params.require(:hostel_room).permit(:name, :beds, :extra_charges)
  end
end
