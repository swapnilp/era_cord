class HostelsController < ApplicationController
  before_action :authenticate_user!
 
  #skip_before_filter :authenticate_with_token!, only: [:download_report]
  load_and_authorize_resource param_method: :my_sanitizer
  
  def index
    return render json: {success: false, message: "Must be root user"} unless @organisation.root?
    
    hostels = Hostel.all
    if params[:student_id].present?
      student = Student.where(id: params[:student_id]).first
    end
    render json: {success: true, hostels: hostels.as_json, student_hostel: student.try(:hostel_id)}
  end

  def create
    return render json: {success: false, message: "Must be root user"} unless @organisation.root?
    
    hostel = @organisation.hostels.build(create_params)
    if hostel.save
      render json: {success: true, id: hostel.id}
    else
      render json: {success: false}
    end
  end

  def show
    return render json: {success: false, message: "Must be root user"} unless @organisation.root?
    
    hostel = Hostel.where(id: params[:id]).first
    if hostel.present?
      render json: {success: true, hostel: hostel.as_json}
    else
      render json: {success: false}
    end
  end
  
  def edit
    return render json: {success: false, message: "Must be root user"} unless @organisation.root?
    
    hostel = Hostel.where(id: params[:id]).first
    if hostel.present?
      render json: {success: true, hostel: hostel.as_json}
    else
      render json: {success: false}
    end
  end

  def update
    return render json: {success: false, message: "Must be root user"} unless @organisation.root?
    
    hostel = Hostel.where(id: params[:id]).first
    return render json: {success: false, message: "Invalid Hostel"} unless hostel.present?
    if hostel.update_attributes(update_params)
      render json: {success: true, id: hostel.id}
    else
      render json: {success: false, messages: hostel.errors.full_messages.join(' , ')}
    end
  end

  def get_unallocated_students
    return render json: {success: false, message: "Must be root user"} unless @organisation.root?
    
    hostel = Hostel.where(id: params[:id]).first
    hostel_room = hostel.hostel_rooms.where(id: params[:room_id]).first
    return render json: {success: false, message: "Invalid Hostel"} unless hostel.present? && hostel_room.present?
    
    students = hostel.students.where(hostel_room_id: nil)
    render json: {success: true, students: students.map(&:hostel_json), remaining_count: hostel_room.remaining_beds}
  end
  
  private
  
  def create_params
    params.require(:hostel).permit(:name, :gender, :rooms, :owner, :address, :average_fee, :student_occupancy, :is_service_tax, :service_tax, :months)
  end

  def update_params
    params.require(:hostel).permit(:name, :gender, :rooms, :owner, :address, :average_fee, :student_occupancy, :is_service_tax, :service_tax, :months)
  end
end
