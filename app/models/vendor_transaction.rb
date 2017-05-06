class VendorTransaction < ActiveRecord::Base
  acts_as_organisation
  
  belongs_to :vendor
  

  def logs_json(options = {})
    options.merge({
                    vender: vendor.name,
                    amount: amount,
                    transaction_type: transaction_type,
                    user_email: user_email,
                    cheque_number: cheque_number,
                    issue_date: issue_date
                    
                  })
  end
end
