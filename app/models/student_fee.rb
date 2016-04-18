class StudentFee < ActiveRecord::Base
  belongs_to :student
  belongs_to :batch
  belongs_to :jkci_class
  belongs_to :organisation
  
  default_scope { where(organisation_id: Organisation.current_id) }    

  after_create :send_account_sms
  
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

  def as_json(options ={})
    options.merge({
                    id: self.id,
                    jkci_class: jkci_class.try(:class_name),
                    date: created_at.strftime("%d/%m/%Y @ %T"),
                    amount: amount,
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
                    name: student.name,
                    parent_name: "#{student.middle_name} #{student.last_name}",
                    p_mobile: student.mobile,
                    jkci_class: jkci_class.try(:class_name),
                    date: created_at.strftime("%d/%m/%Y @ %T"),
                    amount: amount,
                    payment_type: payment_type,
                    bank_name: bank_name,
                    cheque_number: cheque_number,
                    cheque_issue_date: cheque_issue_date,
                    book_number: book_number,
                    receipt_number: receipt_number
                  })
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
    return reports
  end
  
end
