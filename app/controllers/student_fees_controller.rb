class StudentFeesController < ApplicationController
  before_action :authenticate_user!
  
  def index
    if current_user && (FULL_ACCOUNT_HANDLE_ROLES && current_user.roles.map(&:name)).size >0
      fees = StudentFee.includes(:jkci_class, :student).order("id desc")
      student_fees = filter_student_fees(fees)
      total_amount = student_fees.map(&:amount).sum 
      student_fees = student_fees.page(params[:page])
      expected_fees = expected_filter
      render json: {success: true, payments: student_fees.map(&:index_json), total_amount: total_amount, count: student_fees.total_count, expected_fees: expected_fees}
    else
      render json: {success: false}
    end
  end

  def filter_data
    batches = Batch.all
    organisation_standard = @organisation.organisation_standards.all
    render json: {success: true, batches: batches.as_json, standards: organisation_standard.map(&:filter_json)}
  end

  def graph_data
    if current_user && (FULL_ACCOUNT_HANDLE_ROLES && current_user.roles.map(&:name)).size >0
      fees = StudentFee.all
      student_fees = filter_student_fees(fees)
      reports = StudentFee.graph_reports(graph_type="month", student_fees)       
      render json: {success: true, keys: reports.keys, values: reports.values}
    else
      render json: {success: false}
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
      else
        student_fees = []
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
    return student_fees
  end

  def expected_filter
    jkci_classes = JkciClass.all
    if params[:filter].present? &&  JSON.parse(params[:filter])['batch'].present?
      jkci_classes = jkci_classes.where(batch_id: JSON.parse(params[:filter])['batch'])
    end

    if params[:filter].present? &&  JSON.parse(params[:filter])['standard'].present?
      jkci_classes = jkci_classes.where(standard_id: JSON.parse(params[:filter])['batch'])
    end
    fees = jkci_classes.map(&:expected_fee_collections).sum
  end
end
