class ExamsController < ApplicationController
  before_action :authenticate_user!
  before_action :active_standards!, only: [:calender_index, :index]
  load_and_authorize_resource param_method: :my_sanitizer
  #include ExamsHelper


  def index
    #Bullet.enable = false
    if params[:jkci_class_id].present?
      jkci_class = JkciClass.where(id: params[:jkci_class_id]).first
      return render json: {success: false, message: "Invalid Class"} unless jkci_class
      exams = jkci_class.exams.includes({subject: :standard}, {jkci_class: :batch} ).roots.order("exam_date desc") 

      if params[:filter].present? &&  JSON.parse(params[:filter])['filterExamType'].present?
        exams = exams.where(is_group: JSON.parse(params[:filter])['filterExamType'] == "Grouped")
      end
      if params[:filter].present? &&  JSON.parse(params[:filter])['filterExamStatus'].present?
        exams = exams.send(JSON.parse(params[:filter])['filterExamStatus'].downcase.to_sym)
      end
      #@organisation.exams.roots.order("id desc").page(params[:page])
    else
      exams = Exam.joins(:jkci_class).includes({subject: :standard}, {jkci_class: :batch}).roots.where("exams.organisation_id in (?) and jkci_classes.standard_id in (?)", Organisation.current_id, @active_standards).order("exam_date desc")
      #@organisation.exams.roots.order("id desc").page(params[:page])
      if params[:filter].present? &&  JSON.parse(params[:filter])['filterStandard'].present?
        exams = exams.where("jkci_classes.standard_id = ?", JSON.parse(params[:filter])['filterStandard'])
      end
      if params[:filter].present? &&  JSON.parse(params[:filter])['filterBatch'].present?
        exams = exams.where("jkci_classes.batch_id = ?", JSON.parse(params[:filter])['filterBatch'])
      end
      if params[:filter].present? &&  JSON.parse(params[:filter])['filterExamType'].present?
        exams = exams.where(is_group: JSON.parse(params[:filter])['filterExamType'] == "Grouped")
      end
      if params[:filter].present? &&  JSON.parse(params[:filter])['filterExamStatus'].present?
        exams = exams.send(JSON.parse(params[:filter])['filterExamStatus'].downcase.to_sym)
      end
    end
    
    exams = exams.page(params[:page])
    render json: {success: true, body: ActiveModel::ArraySerializer.new(exams, each_serializer: ExamIndexSerializer, scope: {current_organisation: @organisation.id, is_teacher: current_user.has_role?(:teacher)}).as_json, count: exams.total_count}
  end

  def get_filter_data
    standards = @organisation.standards.where("organisation_standards.is_active = ?", true)
    batches = Batch.all
    render json: {success: true, standards: standards.as_json, batches: batches.as_json}
  end

  def calender_index
    exams = Exam.includes({subject: :standard}, :organisation ).joins(:jkci_class).where("jkci_classes.is_current_active = ? && jkci_classes.standard_id in (?) ", true, @active_standards).where(organisation_id: Organisation.current_id)
    if params[:start]
      exams = exams.where("exam_date >= ? ", Date.parse(params[:start]))
    end
    if params[:end]
      exams = exams.where("exam_date <= ? ", Date.parse(params[:end]))
    end
    if params[:standard]
      exams = exams.where("jkci_classes.standard_id = ? ",  params[:standard])
    end
    
    render json: {success: true, exams: exams.map{|exam| exam.calendar_json(@organisation.id, current_user)}}
  end

  def get_descendants
    jkci_class = get_jkci_class
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    if current_user.has_role?(:teacher)
      exam = Exam.includes({subject: :standard}, :jkci_class).where(id: params[:id]).first
    else
      exam = @organisation.exams.includes({subject: :standard}, :jkci_class).where(id: params[:id]).first
    end
      
    if exam
      render json: {success: true, body: ActiveModel::ArraySerializer.new(exam.descendants, each_serializer: ExamIndexSerializer, scope: {current_organisation: @organisation.id}).as_json}
    else
      render json: {success: false}
    end
  end
  
  def show
    jkci_class = get_jkci_class
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    exam = get_exam
    render json: {exam: Exam.json(exam)}
  end
  
  def create
    jkci_class = get_jkci_class
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    exam = jkci_class.exams.build(create_params)
    exam.sub_classes = ",#{ exam.sub_classes}," if exam.sub_classes.present?
    exam.organisation_id = @organisation.id
    if exam.save
      Notification.add_create_exam(exam.id, @organisation) if exam.root?
      render json: {success: true, id: exam.id}
    else
      render json: {success: false, message: exam.errors.full_messages.join(' , ')}
    end
  end

  def upload_paper
    params.permit!
    
    exam = @organisation.exams.where(id: params[:id]).first
    document = exam.documents.build
    document.document = params[:file]
    if document.save
      render json: {success: true}
    else
      render json: {success: false, message: document.errors.full_messages.join(' , ')}
    end
  end
  
  def get_catlogs
    jkci_class = get_jkci_class
    return render json: {success: false, message: "Invalid Calss"} unless jkci_class
    exam = jkci_class.exams.where(id: params[:id]).first
    return render json: {success: false, message: "Invalid Exam"} unless exam
    exam_catlogs = exam.exam_catlogs.includes(:student)
    render json: {success: true, catlogs: ActiveModel::ArraySerializer.new(exam_catlogs, each_serializer: ExamCatlogSerializer).as_json}
  end

  def verify_exam
    jkci_class = get_jkci_class
    return render json: {success: false, message: "Invalid Calss"} unless jkci_class
    exam = @organisation.exams.where(id: params[:id]).first
    if exam
      exam.verify_exam(@organisation)
      render json: {success: true}
    else
      render json: {success: false, message: "Invalid Exam"}
    end
  end


  def exam_conducted
    jkci_class = get_jkci_class
    return render json: {success: false, message: "Invalid Calss"} unless jkci_class
    exam = @organisation.exams.where(id: params[:id]).first
    if exam && exam.create_verification
      exam.complete_exam unless exam.is_completed
      render json: {success: true}
    else
      render json: {success: false, message: "Something went wrong"}
    end
  end

  def add_absunt_students
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
    return render json: {success: false, message: "Invalid Calss"} unless jkci_class
    exam = @organisation.exams.where(id: params[:id]).first
    if exam.create_verification && params[:students_ids].present?
      exam.add_absunt_students(params[:students_ids])
    end
    if exam.create_verification && params[:ignoredStudents].present?
      exam.add_ignore_students(params[:ignoredStudents])
    end
    exam_catlogs = exam.exam_catlogs
    render json: {success: true, catlogs: ActiveModel::ArraySerializer.new(exam_catlogs, each_serializer: ExamCatlogSerializer).as_json}
  end
  
  def add_absunt_student
    jkci_class = get_jkci_class
    return render json: {success: false, message: "Invalid Calss"} unless jkci_class
    exam_catlog = @organisation.exam_catlogs.where(id: params[:catlog_id], exam_id: params[:id]).first
    if exam_catlog
      exam_catlog.update_attributes({is_present: false})
      exam_catlog.exam.update_attributes({verify_absenty: false})
      Notification.add_exam_abesnty(exam_catlog.exam_id, @organisation)
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def remove_absunt_student
    jkci_class = get_jkci_class
    return render json: {success: false, message: "Invalid Calss"} unless jkci_class
    exam_catlog = @organisation.exam_catlogs.where(id: params[:catlog_id], exam_id: params[:id], absent_sms_sent: [false, nil]).first
    if exam_catlog
      exam_catlog.update_attributes({is_present: nil, is_recover: nil})
      exam_catlog.exam.update_attributes({verify_absenty: false})
      Notification.add_exam_abesnty(exam_catlog.exam_id, @organisation)
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def add_ignored_student
    jkci_class = get_jkci_class
    return render json: {success: false, message: "Invalid Calss"} unless jkci_class
    exam_catlog = @organisation.exam_catlogs.where(id: params[:catlog_id], exam_id: params[:id]).first
    if exam_catlog
      exam_catlog.update_attributes({is_ingored: true})
      #exam_catlog.exam.update_attributes({verify_absenty: false})
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def remove_ignored_student
    jkci_class = get_jkci_class
    return render json: {success: false, message: "Invalid Calss"} unless jkci_class
    exam_catlog = @organisation.exam_catlogs.where(id: params[:catlog_id], exam_id: params[:id], absent_sms_sent: [false, nil]).first
    if exam_catlog
      exam_catlog.update_attributes({is_ingored: nil, is_recover: nil})
      #exam_catlog.exam.update_attributes({verify_absenty: false})
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def add_exam_results
    jkci_class = get_jkci_class
    return render json: {success: false, message: "Invalid Calss"} unless jkci_class
    exam = @organisation.exams.where(id: params[:id]).first
    if exam && exam.create_verification && params[:students_results].present?
      exam.add_exam_results(params[:students_results])
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def publish_exam_result
    jkci_class = get_jkci_class
    return render json: {success: false, message: "Invalid Calss"} unless jkci_class
    exam = @organisation.exams.where(id: params[:id]).first
    if exam && exam.verify_absenty && exam.verify_result
      exam.publish_results
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def verify_exam_result
    jkci_class = get_jkci_class
    return render json: {success: false, message: "Invalid Calss"} unless jkci_class
    exam = @organisation.exams.where(id: params[:id]).first
    if exam
      exam.verify_exam_result
      render json: {success: true}
    else
      render json: {success: false}
    end
  end
  
  def verify_exam_absenty
    jkci_class = get_jkci_class
    return render json: {success: false, message: "Invalid Calss"} unless jkci_class
    exam = @organisation.exams.where(id: params[:id]).first
    if exam
      exam.verify_presenty(@organisation)
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def get_exam_info
    jkci_class = get_jkci_class
    return render json: {success: false, message: "Invalid Calss"} unless jkci_class
    exam = @organisation.exams.where(id: params[:id]).first
    if exam && exam.is_group
      render json: {success: true, data: GroupExamDataSerializer.new(exam).as_json} 
    else
      render json: {success: false}
    end
  end

  def edit
    jkci_class = get_jkci_class
    return render json: {success: false, message: "Invalid Calss"} unless jkci_class
    exam = jkci_class.exams.where(id: params[:id]).first
    sub_classes = jkci_class.sub_classes.select([:id, :name, :jkci_class_id, :destription])
    subjects = jkci_class.standard.subjects
    
    if exam && !exam.is_completed
      exam_sub_classes = sub_classes.as_json({selected: exam.sub_classes.to_s.split(',').map(&:to_i)})
      render json: {success: true, exam: exam, 
        sub_classes: exam_sub_classes, 
        subjects: subjects.as_json({selected: [exam.subject_id]})}
    else
      render json: {success: false}
    end
  end

  def update
    exam = @organisation.exams.where(id: params[:id]).first
    if exam && exam.update(update_params)
      if exam.sub_classes.present?
        sub_classes = ",#{exam.sub_classes.split(',').delete_if(&:empty?).join(',')}," 
        exam.update_attributes({sub_classes: sub_classes})
      end
      render json: {success: true, id: exam.id}
    else
      render json: {success: false}
    end
  end


  def remove_exam_result
    jkci_class = get_jkci_class
    return render json: {success: false, message: "Invalid Calss"} unless jkci_class
    
    exam = @organisation.exams.where(id: params[:id]).first
    if exam
      exam.remove_exam_result(params[:exam_catlog_id])
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def group_exam_report
    jkci_class = get_jkci_class
    return render json: {success: false, message: "Invalid Calss"} unless jkci_class
    
    exam = get_exam
    if exam
      table_head = exam.grouped_exam_report_table_head
      table_data = exam.grouped_exam_report
      render json: {success: true, table_head: table_head, table_data: table_data}
    else
      render json: {success: false}
    end
    
  end

  def manage_points
    jkci_class = get_jkci_class
    return render json: {success: false, message: "Invalid Calss"} unless jkci_class
    
    exam = @organisation.exams.where(id: params[:id]).first
    if exam
      points = ChaptersPoint.where(chapter_id: exam.chapters_points.map(&:chapter_id))
      selected_points = exam.chapters_points.map(&:id)
      render json:{success: true, chapters: exam.subject.chapters.as_json, selected_chapters: exam.chapters_points.map(&:chapter_id).uniq, points: points.as_json, selected_points: selected_points}
    else
      render json: {success: false}
    end
  end

  def get_chapters_points
    jkci_class = get_jkci_class
    return render json: {success: false, message: "Invalid Calss"} unless jkci_class
    
    exam = @organisation.exams.where(id: params[:id]).first
    if exam
      points = ChaptersPoint.joins([:chapter]).where("chapters.id in (?)", [0] + params[:chapter_ids].split(',')).as_json
      render json:{success: true, points: points}
    else
      render json: {success: false}
    end
  end

  def save_exam_points
    jkci_class = get_jkci_class
    return render json: {success: false, message: "Invalid Calss"} unless jkci_class
    
    exam = @organisation.exams.where(id: params[:id]).first
    if exam
      exam.save_exam_points(params[:point_ids])
      render json: {success: true}
    else
      render json: {success: false}
    end
  end
  
  def destroy
    jkci_class = get_jkci_class
    return render json: {success: false, message: "Invalid Calss"} unless jkci_class
    
    exam = jkci_class.exams.where(id: params[:id]).first
    if exam && !exam.create_verification
      exam.update_attributes({is_active: false})
      exam.descendants.update_all({is_active: false})
      exam.delete_notification if exam.root?
      back_url = exam.root? ? "/classes/#{exam.jkci_class_id}" : "/classes/#{exam.jkci_class_id}/exams/#{exam.root.id}/show" 

      render json: {success: true, backUrl: back_url}
    else
      render json: {success: false}
    end
  end



  private

  def get_jkci_class
    if current_user.has_role?(:teacher)
      jkci_class = JkciClass.where(id: params[:jkci_class_id]).first
    else
      jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
    end
    return jkci_class
  end

  def get_exam
    if current_user.has_role?(:teacher)
      exam = Exam.where(id: params[:id]).first
    else
      exam = @organisation.exams.where(id: params[:id]).first
    end
    return exam
  end
  
  def my_sanitizer
    #params.permit!
    params.require(:exam).permit!
  end
  
  def create_params
    params.require(:exam).permit(:name, :conducted_by, :marks, :exam_date, :duration, :subject_id, :exam_type, :sub_classes, :jkci_class_id, :is_group, :ancestry)
  end

  def update_params
    params.require(:exam).permit(:name, :marks, :subject_id, :exam_date, :exam_type, :jkci_class_id, :is_group, :conducted_by, :duration, :sub_classes, :ancestry)
  end

end
