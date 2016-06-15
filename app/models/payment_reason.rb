class PaymentReason < ActiveRecord::Base

  has_many :student_fees

  def as_json(options= {})
    options.merge({
                    id: id,
                    reason: reason
                  })
    
  end
end
