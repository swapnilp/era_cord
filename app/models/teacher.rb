class Teacher < ActiveRecord::Base
  #attr_accessor :subject_id, :first_name, :last_name, :mobile, :email, :address
  acts_as_organisation
  

  has_many :teacher_subjects, dependent: :destroy
  has_many :subjects, through: :teacher_subjects
  has_many :daily_teaching_points
  belongs_to :g_teacher
  has_many :standards, through: :subjects
  has_many :time_table_classes
  has_many :jkci_classes, through: :time_table_classes
  has_many :off_classes
  
  #validates :email, uniqueness: true, presence: true
  validates_uniqueness_of :email, :scope => :organisation_id, :case_sensitive => false, presence: true
  
  scope :active, -> { where(active: true) }
  
  def name
    "#{first_name} #{last_name}"
  end

  def user
    organisation.users.teachers.where(email: self.email).first
  end

  def self.get_g_teacher(teacher_params, org)
    gt = GTeacher.find_or_initialize_by(teacher_params.slice(:email))
    gt.first_name = teacher_params[:first_name]
    gt.last_name = teacher_params[:last_name]
    gt.mobile = teacher_params[:mobile]
    gt.address = teacher_params[:address]
    new_record = gt.new_record?
    gt.save
    return gt
  end

  def remaining_subjects(org)
    subjects = Subject.includes(:standard).where("standard_id in (?) && id not in (?)", [0] + org.organisation_standards.map(&:standard_id), [0] + teacher_subjects.map(&:subject_id))
  end

  def save_subjects(org, subject_ids)
    Subject.includes(:standard).where("standard_id in (?) && id in (?)", [0] + org.organisation_standards.map(&:standard_id), [0] + subject_ids).each do |subject|
      teacher_subjects.find_or_initialize_by({subject_id: subject.id, organisation_id: org.id}).save
    end
  end

  def remove_subject(subject_id)
    teacher_subjects.where(id: subject_id).first.try(:destroy)
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

  def filter_json(options={})
    options.merge({
                    id: self.id,
                    name: self.name
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
