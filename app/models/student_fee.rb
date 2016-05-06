class StudentFee < ActiveRecord::Base
  belongs_to :student
  belongs_to :batch
  belongs_to :jkci_class
  belongs_to :organisation
  belongs_to :user
  has_one :class_student, :class_name => "ClassStudent", :foreign_key => "student_id", primary_key: "student_id"
  
  default_scope { where(organisation_id: Organisation.current_id) }    

  after_create :send_account_sms
  validates_presence_of :student_id, :batch_id, :date, :amount,  :payment_type, :organisation_id, :user_id
  
  def send_account_sms
    #org = Organisation.where(email: self.email).first
    if self.organisation.root.account_sms.present?
      Delayed::Job.enqueue FeeAccountSms.new(fee_paid_sms)
    end
  end

  def fee_paid_sms
    message = "#{self.student.name} is deposited #{self.amount} fee on #{self.date.to_date} in #{self.organisation.root.name}"
    url = "https://www.txtguru.in/imobile/api.php?username=#{SMSUNAME}&password=#{SMSUPASSWORD}&source=update&dmobile=91#{self.organisation.root.account_sms}&message=#{message}"
    url_arry = [url, message, self.id, self.organisation.root.id]
  end

  def print_data
    {
      id: id,
      student_name: student.name, 
      mobile: student.p_mobile, 
      amount: amount, 
      service_tax: service_tax.to_f.round(2), 
      class_name: jkci_class.try(:class_name), 
      date: date.to_date, 
      pan_number: organisation.pan_number, 
      tan_number: organisation.tan_number,
      organisation_name: organisation.name,
      enable_service_tax: organisation.enable_service_tax,
      s_tax: organisation.service_tax.to_f.round(2),
      payment_type: payment_type,
      bank_name: bank_name,
      cheque_number: cheque_number,
      cheque_issue_date: cheque_issue_date,
      book_number: book_number,
      receipt_number: receipt_number,
      user: user.try(:email)
    }
  end

  def self.index_fee_json(index_arr)
    {
      name: index_arr.first.student.name , 
      parent_name: "#{index_arr.first.student.middle_name} #{index_arr.first.student.last_name}", 
      p_mobile: index_arr.first.student.mobile,
      jkci_class: index_arr.first.jkci_class.try(:class_name),
      student_id: index_arr.first.student_id,
      collected_fee: index_arr.map(&:amount).sum,
      remaining_fee: index_arr.first.remaining_fee,
      :transactions => index_arr.map(&:index_json),
      total_transactions: index_arr.count
    }
  end

  def as_json(options ={})
    options.merge({
                    id: self.id,
                    student_id: student_id,
                    jkci_class: jkci_class.try(:class_name),
                    date: created_at.strftime("%d/%m/%Y @ %T"),
                    amount: amount,
                    service_tax: service_tax,
                    payment_type: payment_type,
                    bank_name: bank_name,
                    cheque_number: cheque_number,
                    cheque_issue_date: cheque_issue_date,
                    book_number: book_number,
                    receipt_number: receipt_number
                  })
  end

  def index_json(options ={})
    options.merge({
                    id: id,
                    student_id: student_id,
                    date: created_at.strftime("%d/%m/%Y @ %T"),
                    amount: amount,
                    service_tax: service_tax,
                    payment_type: payment_type,
                    bank_name: bank_name,
                    cheque_number: cheque_number,
                    cheque_issue_date: cheque_issue_date,
                    book_number: book_number,
                    receipt_number: receipt_number,
                  })
  end

  def remaining_fee
    col_fee = self.class_student.try(:collected_fee) || 0
    class_fee = self.class_student.try(:jkci_class).try(:fee) || 0
    return (class_fee - col_fee)
  end

  def self.graph_reports(graph_type="month", student_fees= [])
    reports = {}
    if graph_type == "day"
      reports = student_fees.where("date > ?", Date.today - 50.days).group_by_period(graph_type.to_sym, "date", format: "%d-%b").sum(:amount)
    end
    if graph_type == "week"
      reports = student_fees.where("date > ?", Date.today - 30.weeks).group_by_period(graph_type.to_sym, "date", format: "%d-%b", week_start: :mon).sum(:amount)
    end
    if graph_type == "month"
      reports = student_fees.where("date > ?", Date.today - 10.months).group_by_period(graph_type.to_sym, "date", format: "%b-%Y").sum(:amount)
    end
    reports.each { |k, v| reports[k] = v.round(2) }
    return reports
  end
  
end
