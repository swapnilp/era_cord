class OrganisationStandard < ActiveRecord::Base

  acts_as_organisation
  validates_uniqueness_of :standard_id, scope: :organisation_id


  scope :active, lambda{ where(is_active: true) }

  belongs_to :standard

  belongs_to :assigned_organisation, class_name: "Organisation", foreign_key: "assigned_organisation_id"
  
  after_create :create_organisation_calss
  
  def create_organisation_calss
  end

  class << self
    def explicit_pull_back
      organisation_standards = OrganisationStandard.unscoped.where(is_assigned_to_other: true)
      organisation_standards.each do |organisation_standard|
        if organisation_standard.assigned_organisation.nil? && organisation_standard.organisation.present?
          Thread.current[:organisation_id] = organisation_standard.organisation_id
          [ExamPoint, Exam, ExamCatlog, DailyTeachingPoint, ClassCatlog, SubClass, StudentSubject, Student, ClassStudent, Notification, TimeTableClass, TimeTable, OffClass, JkciClass].each do |obj|
            obj.unscoped.where(organisation_id: organisation_standard.assigned_organisation_id).update_all({organisation_id: organisation_standard.organisation_id})
          end
          OrganisationStandard.unscoped.where(organisation_id: organisation_standard.assigned_organisation_id, standard_id: organisation_standard.standard_id).destroy_all
          organisation_standard.update_attributes({assigned_organisation_id: nil, is_assigned_to_other: false})
          Thread.current[:organisation_id] = nil
        end
      end
    end
  end

  def as_json(options = {}, org  = nil)
    options.merge({
                    id: id,
                    standard_id: standard_id,
                    organisation_id: organisation_id,
                    organisation_name: organisation.try(:name),
                    is_active: is_active,
                    is_assigned_to_other: is_assigned_to_other,
                    assigned_organisation_id: assigned_organisation_id,
                    is_parent_organisation: organisation.root?,
                    is_children: org.present? ? org.descendants.exists?(id: self.organisation_id) : nil,
                    email: organisation.email,
                    mobile: organisation.mobile
                  })
    
  end

  def filter_json(options ={})
    options.merge({
                    id: id,
                    standard_id: standard_id,
                    name: standard.name
                  })
  end

end
