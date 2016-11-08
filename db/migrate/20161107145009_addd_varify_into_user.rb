class AdddVarifyIntoUser < ActiveRecord::Migration
  def change
    add_column :users, :verify_mobile, :boolean, default: false
    add_column :users, :mobile_token, :string
    
    User.all.each do |u|
      if u.role == "organisation"
        u.update_attributes({mobile: u.organisation.mobile})
      elsif u.role == "teacher"
        mobile = GTeacher.where(email: u.email).first.mobile
        u.update_attributes({mobile: mobile})
      end
    end
    
  end
end
