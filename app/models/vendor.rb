class Vendor < ActiveRecord::Base
  acts_as_organisation
  
  validates_presence_of :name, :nick_name, :mobile, :reason
  
  has_many :vendor_transactions

end
