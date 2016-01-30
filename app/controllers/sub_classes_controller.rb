class SubClassesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource param_method: :my_sanitizer

  def index
    jkci_class = JkciClass.where(id: params[:jkci_class_id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    sub_classes = jkci_class.sub_classes
    render json: {success: true, sub_classes: sub_classes.map(&:index_json)}
  end
  
  def show
    jkci_class = JkciClass.where(id: params[:jkci_class_id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    sub_class = jkci_class.sub_classes.where(id: params[:id]).first
    if sub_class
      render json: {success: true, sub_class: sub_class.as_json}
    else
      render json: {success: false}
    end
    #@students = @sub_class.students
  end
  
  def create 
    jkci_class = JkciClass.where(id: params[:jkci_class_id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    
    sub_class = jkci_class.sub_classes.build(params[:sub_class].merge({organisation_id: @organisation.id}))
    if sub_class.save
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def students
    jkci_class = JkciClass.where(id: params[:jkci_class_id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class

    sub_class = jkci_class.sub_classes.where(id: params[:id]).first
    if sub_class
      students = sub_class.students.includes(:batch, :standard)
      render json: {success: true, students: students.map(&:sub_class_json)}
    else
      render json: {success: false}
    end  
  end

  def remaining_students
    jkci_class = JkciClass.where(id: params[:jkci_class_id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class

    sub_class_students = jkci_class.sub_classes.where(id: params[:id]).first.try(&:students)
    sub_class_students_ids = sub_class_students.map(&:id) || []
    sub_class_students_ids << 0
    students = jkci_class.students.where("students.id not in (?)", sub_class_students_ids)
    
    render json: {success: true, students: students.map(&:sub_class_remaining_json)}
  end

  def add_students
    jkci_class = JkciClass.where(id: params[:jkci_class_id]).first
    if jkci_class
      jkci_class.add_sub_class_students(params[:students], params[:id])
      render json: {success: true}
    else
      render json: {success: false}
    end
  end
  
  def remove_student
    jkci_class = JkciClass.where(id: params[:jkci_class_id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    
    jkci_class.remove_sub_class_students(params[:student_id], params[:id])
    render json: {success: true}
  end

  def destroy
    jkci_class = JkciClass.where(id: params[:jkci_class_id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    
    sub_class = jkci_class.sub_classes.where(id: params[:id]).first
    if sub_class
      sub_class.students.select([:id, :organisation_id]).each do |student|
        jkci_class.remove_sub_class_students(student.id, params[:id])
      end
      sub_class.destroy
      render json: {success: true}
    else
      render json: {success: false, message: "Invalid Class"}
    end
  end
  
  private
  
  def my_sanitizer
    #params.permit!
    params.require(:sub_class).permit!
  end
end
