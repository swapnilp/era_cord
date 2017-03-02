class VendorTransaction < ActiveRecord::Base

  belongs_to :vendor
  belongs_to :organisation
  
  default_scope { where(organisation_id: Organisation.current_id) }  

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
