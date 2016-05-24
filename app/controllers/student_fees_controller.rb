class StudentFeesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource 
  
  
  def index
    if current_user && (FULL_ACCOUNT_HANDLE_ROLES && current_user.roles.map(&:name)).size >0 && @organisation.root?
      fees = StudentFee.includes(:jkci_class, :student, {class_student: :jkci_class}).order("id desc")
      student_fees = filter_student_fees(fees)
      total_amount = student_fees.map(&:amount).sum
      total_tax = student_fees.map(&:service_tax).sum
      expected_fees = expected_filter
      total_students = student_fees.map(&:student_id).uniq.count
      #student_fees = student_fees.page(params[:page])
      #student_fees = Kaminari.paginate_array(student_fees.group_by{ |s| [s.student_id, s.jkci_class_id] }.values).page(2).per(2)
      fees_group = student_fees.group_by{ |s| [s.student_id, s.jkci_class_id] }
      student_fees_index = fees_group.values.collect {|fee_g| StudentFee.index_fee_json(fee_g)}
      if params[:filter].present? &&  JSON.parse(params[:filter])['is_remaining'] == 'Remaining'
        student_ids = student_fees_index.collect {|student| student[:student_id]}
        remaining_students = StudentFee.remaining_students(student_ids, params[:filter])
        student_fees_index = student_fees_index + remaining_students
      end
      student_fees_index = Kaminari.paginate_array(student_fees_index).page(params[:page]).per(10)
      #student_fees_index = Kaminari.paginate_array(fees_group.values).map {|a| StudentFee.index_fee_json(a) }
      render json: {success: true, payments: student_fees_index, total_amount: total_amount, count: student_fees_index.total_count, expected_fees: expected_fees, total_students: student_fees_index.total_count, total_tax: total_tax.round(2)}
    else
      render json: {success: false, message: "Unauthorized !!!! You Must be Root Organisation."}
    end
  end

  def filter_data
    if current_user && (FULL_ACCOUNT_HANDLE_ROLES && current_user.roles.map(&:name)).size >0 && @organisation.root?
      batches = Batch.all
      organisation_standard = @organisation.organisation_standards.all
      render json: {success: true, batches: batches.as_json, standards: organisation_standard.map(&:filter_json)}
    else
      render json: {success: false, message: "Unauthorized !!!! You Must be Root Organisation."}
    end
  end

  def graph_data
    if current_user && (FULL_ACCOUNT_HANDLE_ROLES && current_user.roles.map(&:name)).size >0 && @organisation.root?
      fees = StudentFee.all
      student_fees = filter_student_fees(fees)
      if params[:filter].present?  
        acc_type= JSON.parse(params[:filter])['selectedAccountType'] || 'Both'
        acc_span = JSON.parse(params[:filter])['selectedAccountSpan'] || 'month'
        reports = StudentFee.graph_reports(acc_span, student_fees, acc_type)
      else
        reports = StudentFee.graph_reports(graph_type="month", student_fees)
      end
      render json: {success: true, keys: reports.keys, values: reports.values, total_amount: reports.values.sum, min_date: reports.keys.map(&:to_date).min, max_date: reports.keys.map(&:to_date).max}
    else
      render json: {success: false, message: "Unauthorized. You Must be Root Organisation."}
    end
  end

  def print_receipt
    if current_user && (FULL_ACCOUNT_HANDLE_ROLES && current_user.roles.map(&:name)).size >0 && @organisation.root?
      student_fee = StudentFee.where(id: params[:id], student_id: params[:student_id]).first
      if student_fee
        render json: {success: true, print_data: student_fee.print_data}
      else
        render json: {success: false, message: "Receipt not found"}
      end
    else
      render json: {success: false, message: "Unauthorized. You Must be Root Organisation."}
    end
  end

  def print_account
    fees = StudentFee.includes(:jkci_class, :student, {class_student: :jkci_class}).order("id desc")
    student_fees = filter_student_fees(fees)
    fees_groups = student_fees.group_by{ |s| [s.student_id, s.jkci_class_id] }
    account_json = fees_groups.values.collect {|fee_group| StudentFee.print_fee_json(fee_group)}
    if params[:filter].present? &&  JSON.parse(params[:filter])['is_remaining'] == 'Remaining'
      student_ids = account_json.collect {|student| student[:student_id]}
      remaining_students = StudentFee.remaining_students(student_ids, params[:filter])
      account_json = account_json+ remaining_students
    end
    render json: {success: true, data:  account_json}
  end

  def download_excel
    fees = StudentFee.includes(:jkci_class, :student, {class_student: :jkci_class}).order("id desc")
    student_fees = filter_student_fees(fees)
    fees_groups = student_fees.group_by{ |s| [s.student_id, s.jkci_class_id] }
    @accounts = fees_groups.values.collect {|fee_group| StudentFee.print_fee_json(fee_group)}
    if params[:filter].present? &&  JSON.parse(params[:filter])['is_remaining'] == 'Remaining'
      student_ids = @accounts.collect {|student| student[:student_id]}
      remaining_students = StudentFee.remaining_students(student_ids, params[:filter])
      @accounts = @accounts + remaining_students
    end
    respond_to do |format|
      format.xlsx{
        response.headers['Content-Disposition'] = "attachment; filename='accounts_#{Date.today.strftime("%v")}.xlsx'"
      }
    end
  end

  protected

  def filter_student_fees(student_fees)
    if params[:filter].present? &&  JSON.parse(params[:filter])['batch'].present?
      student_fees = student_fees.where(batch_id: JSON.parse(params[:filter])['batch'])
      batch_id = JSON.parse(params[:filter])['batch']
    else
      student_fees = student_fees.where(batch_id: Batch.active.last.id)
      batch_id = Batch.active.last.id
    end
    
    if params[:filter].present? &&  JSON.parse(params[:filter])['standard'].present?
      jkci_class = JkciClass.where(standard_id: JSON.parse(params[:filter])['standard'], batch_id: batch_id).first
      if jkci_class.present?
        student_fees = student_fees.where(jkci_class_id: jkci_class.try(:id))
      end
    end
    if params[:filter].present? &&  JSON.parse(params[:filter])['payment_type'].present?
      student_fees = student_fees.where("payment_type = ?", JSON.parse(params[:filter])['payment_type'])
    end
    if params[:filter].present? &&  JSON.parse(params[:filter])['name'].present?
      query = "%#{JSON.parse(params[:filter])['name']}%"
      student_ids = Student.where("CONCAT_WS(' ', first_name, last_name) LIKE ? || CONCAT_WS(' ', last_name, first_name) LIKE ? || p_mobile like ?", query, query, query).map(&:id)
      student_fees = student_fees.where(student_id: student_ids)
    end
    if params[:filter].present? &&  JSON.parse(params[:filter])['is_remaining'] == 'Remaining'
      student_fees = student_fees.select{|sf| sf.remaining_fee > 0}
    end
    return student_fees
  end

  def expected_filter
    ## expected fees with Filter ##
    jkci_classes = JkciClass.all
    if params[:filter].present? &&  JSON.parse(params[:filter])['batch'].present?
      jkci_classes = jkci_classes.where(batch_id: JSON.parse(params[:filter])['batch'])
    else
      jkci_classes = jkci_classes.where(batch_id: Batch.active.last.id)
    end

    if params[:filter].present? &&  JSON.parse(params[:filter])['standard'].present?
      jkci_classes = jkci_classes.where(standard_id: JSON.parse(params[:filter])['standard'])
    end
    fees = jkci_classes.map(&:expected_fee_collections).sum
  end
end
