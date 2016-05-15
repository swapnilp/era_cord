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
    render json: {success: true, body: ActiveModel::ArraySerializer.new(exams, each_serializer: ExamIndexSerializer, scope: {current_organisation: @organisation.id}).as_json, count: exams.total_count}
  end

  def get_filter_data
    standards = @organisation.standards
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
    
    render json: {success: true, exams: exams.map{|exam| exam.calendar_json(@organisation.id)}}
  end

  def get_descendants
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    exam = @organisation.exams.includes({subject: :standard}, :jkci_class).where(id: params[:id]).first
    if exam
      render json: {success: true, body: ActiveModel::ArraySerializer.new(exam.descendants, each_serializer: ExamIndexSerializer, scope: {current_organisation: @organisation.id}).as_json}
    else
      render json: {success: false}
    end
  end
  
  def show
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    exam = @organisation.exams.where(id: params[:id]).first
    render json: {exam: Exam.json(exam)}
  end
  
  def create
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
    return render json: {success: false, message: "Invalid Class"} unless jkci_class
    exam = jkci_class.exams.build(create_params)
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
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
    return render json: {success: false, message: "Invalid Calss"} unless jkci_class
    exam = jkci_class.exams.where(id: params[:id]).first
    return render json: {success: false, message: "Invalid Exam"} unless exam
    exam_catlogs = exam.exam_catlogs.includes(:student)
    render json: {success: true, catlogs: ActiveModel::ArraySerializer.new(exam_catlogs, each_serializer: ExamCatlogSerializer).as_json}
  end

  def verify_exam
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
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
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
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
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
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
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
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
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
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
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
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
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
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
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
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
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
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
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
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
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
    return render json: {success: false, message: "Invalid Calss"} unless jkci_class
    exam = @organisation.exams.where(id: params[:id]).first
    if exam && exam.is_group
      render json: {success: true, data: GroupExamDataSerializer.new(exam).as_json} 
    else
      render json: {success: false}
    end
  end

  def edit
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
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
      render json: {success: true, id: exam.id}
    else
      render json: {success: false}
    end
  end


  def remove_exam_result
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
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
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
    return render json: {success: false, message: "Invalid Calss"} unless jkci_class
    
    exam = @organisation.exams.where(id: params[:id]).first
    if exam
      table_head = exam.grouped_exam_report_table_head
      table_data = exam.grouped_exam_report
      render json: {success: true, table_head: table_head, table_data: table_data}
    else
      render json: {success: false}
    end
    
  end

  def manage_points
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
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
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
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
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
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
    jkci_class = @organisation.jkci_classes.where(id: params[:jkci_class_id]).first
    return render json: {success: false, message: "Invalid Calss"} unless jkci_class
    
    exam = jkci_class.exams.where(id: params[:id]).first
    if exam && !exam.create_verification
      exam.update_attributes({is_active: false})
      exam.delete_notification if exam.root?
      back_url = exam.root? ? "/classes/#{exam.jkci_class_id}" : "/classes/#{exam.jkci_class_id}/exams/#{exam.root.id}/show" 

      render json: {success: true, backUrl: back_url}
    else
      render json: {success: false}
    end
  end


  ####################
  


  def download_data
    @exam = @organisation.exams.where(id: params[:id]).first
    @exam_catlogs = @exam.exam_table_format
    filename = "#{@exam.name}.xls"
    respond_to do |format|
      format.xls { headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" }
      format.pdf { render :layout => false }
    end
  end


  
  
  


  def verify_create_exam
    exam = @organisation.exams.where(id: params[:id]).first
    if exam
      exam.verify_exam(@organisation)
    end
    redirect_to exam_path(exam)
  end
  
  
  
  

  def absunts_students
    @exam = @organisation.exams.where(id: params[:id]).first
    #ids = [0] << @exam.exam_absents.map(&:student_id) 
    #ids << @exam.exam_results.map(&:student_id)
    students_ids = @exam.exam_catlogs.where(is_present: nil, is_ingored: [nil, false]).map(&:student_id)
    @students = @exam.students.where(id: students_ids)
  end


  def recover_exam
    #@exam = Exam.where(id: params[:id]).first
    exam_catlog = @organisation.exam_catlogs.where(id: params[:exam_catlog_id]).first
    exam_catlog.update_attributes({is_recover: true, recover_date: Date.today})
    redirect_to exam_path(params[:id])
  end

  def exams_students
    @exam = @organisation.exams.where(id: params[:id]).first
    @absent_students = @exam.absent_students
    @students = @exam.students.where("(exam_catlogs.is_present is ? && exam_catlogs.marks is ? && exam_catlogs.is_ingored is ?) || (exam_catlogs.is_present = ? && exam_catlogs.marks is ? && exam_catlogs.is_recover = ? && exam_catlogs.is_ingored is ?)", nil, nil, nil, false, nil, true, nil)
  end

  


  def publish_absent_exam
    @exam = @organisation.exams.where(id: params[:id]).first
    if @exam && @exam.verify_absenty
      @exam.publish_absentee
    end
    redirect_to exam_path(@exam)
  end
  
  def exam_completed
    @exam = @organisation.exams.where(id: params[:id]).first
    if @exam && @exam.create_verification
      @exam.complete_exam unless @exam.is_completed
    end
    redirect_to exam_path(@exam)
  end
  
  def filter_exam
    exams = params[:class_id].present? ? @organisation.exams.roots.where("jkci_class_id = ? OR class_ids like ?", params[:class_id], "%,#{params[:class_id]},%") : @organisation.exams.roots
    if params[:type].present?
      exams = exams.where(exam_type: params[:type])
    end
    if params[:status].present?
      if params[:status] == "Created"
        exams = exams.where(is_completed: [nil, false])
      elsif params[:status] == "Conducted"
        exams = exams.where(is_completed: true, is_result_decleared: [nil, false])
      elsif params[:status] == "Published"
        exams = exams.where(is_result_decleared: true)
      end
    end
    exams = exams.order("id desc").page(params[:page]).per(10);
    pagination_html = render_to_string(partial: 'pagination.html.erb', layout: false, locals: {exams: exams})
    render json: {success: true, count: exams.total_count, html: render_to_string(:partial => "exam.html.erb", :layout => false, locals: {exams: exams}), pagination_html:  pagination_html, css_holder: ".examsTable tbody"}
  end

  def download_exams_report
    exams = params[:class_id].present? ? @organisation.exams.roots.where("jkci_class_id = ? OR class_ids like ?", params[:class_id], "%,#{params[:class_id]},%") : @organisation.exams.roots
    if params[:type].present?
      exams = exams.where(exam_type: params[:type])
    end
    if params[:status].present?
      if params[:status] == "Created"
        exams = exams.where(is_completed: [nil, false])
      elsif params[:status] == "Conducted"
        exams = exams.where(is_completed: true, is_result_decleared: [nil, false])
      elsif params[:status] == "Published"
        exams = exams.where(is_result_decleared: true)
      end
    end

    if params[:class_id].present?
      @jkci_class = @organisation.jkci_classes.where(id: params[:class_id]).first
    end

    @exams_count = exams.count
    @exams_table_format = exams_table_format(exams)

    respond_to do |format|
      format.pdf { render :layout => false }
    end
  end

  def follow_exam_absent_student
    exam_catlog = @organisation.exam_catlogs.where(id: params[:exam_catlog_id]).first
    exam_catlog.update_attributes({is_followed: true}) if exam_catlog
    render json: {success: true}
  end

  #def upload_paper
  #  params.permit!
  #  attachment = @organisation.documents.build(params[:document])
  #  attachment.exam_id= params[:exam_id]
  #  if attachment.save     
  #    respond_to do |format|
  #      format.json {render json: {success: true, id: attachment.id, url: attachment.document.url, name: attachment.document_file_name}}
  #    end
  #  else
  #    Rails.logger.info attachment.errors.inspect
  #    respond_to do |format|
  #      format.json {render json: {success: false, msg: attachment.errors.messages.values.first.first}}
  #    end
  #  end
  #end

  def ignore_student
    exam = @organisation.exams.where(id: params[:id]).first
    if exam 
      exam.add_ignore_student(params[:student_id])
    end
    redirect_to exam_path(exam)
  end
  
  def remove_ignore_student
    exam = @organisation.exams.where(id: params[:id]).first
    if exam 
      exam.remove_ignore_student(params[:student_id])
    end
    redirect_to exam_path(exam)
  end

  private
  
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
