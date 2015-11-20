class Result < ActiveRecord::Base
  belongs_to :bach_result

  scope :published, -> {where('')}
 # attr_accessible :first_name, :middle_name, :last_name, :email, :mobile, :parent_name, :p_mobile, :p_email, :address, :group, :rank

  #has_many


  def student_image 
    student_img.present? ? student_img :  "/assets/img/man_icon.png"
  end
  
end
