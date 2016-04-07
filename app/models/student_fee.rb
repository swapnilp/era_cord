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
                    id: id,
                    jkci_class: jkci_class.try(:class_name),
                    date: date.to_date,
                    amount: amount,
                    payment_type: payment_type,
                    bank_name: bank_name,
                    cheque_number: cheque_number,
                    cheque_issue_date: cheque_issue_date,
                    book_number: book_number,
                    receipt_number: receipt_number
                  })
  end
  
end
