class Teacher < ActiveRecord::Base
  #attr_accessor :subject_id, :first_name, :last_name, :mobile, :email, :address

  has_many :teacher_subjects
  has_many :subjects, through: :teacher_subjects
  has_many :daily_teaching_points

  validates :email, uniqueness: true, presence: true
  
  default_scope { where(organisation_id: Organisation.current_id) }  
  
  def name
    "#{first_name} #{last_name}"
  end

  def as_json(options={})
    options.merge({
                    id: self.id,
                    name: self.name,
                    mobile: self.mobile,
                    email: self.email,
                    is_full_time: self.is_full_time
                  })
  end

  def edit_json(options={})
    options.merge({
                    id: self.id,
                    first_name: self.first_name,
                    last_name: self.last_name,
                    mobile: self.mobile,
                    email: self.email,
                    is_full_time: self.is_full_time
                  })
  end
end
