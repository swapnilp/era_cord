class SubClass < ActiveRecord::Base
  belongs_to :jkci_class
  has_many :class_students, through: :jkci_class
  
  default_scope { where(organisation_id: Organisation.current_id) }
  
  def students
    ids = class_students.where("sub_class like '%,?,%'", self.id).map(&:student_id)
    self.jkci_class.students.where("students.id in (?)", ids)
  end

  def disp_name
    "#{name}-#{self.students.count}"
  end

  def as_json(options= {})
    output = if options[:selected].present?
               options.merge({
                               id: self.id,
                               name: name,
                               ticked: options[:selected].include?(id)
                             })
             else
               options.merge({
                               id: self.id,
                               name: name
                             })
             end
    output.tap{|x| x.delete(:selected)} 
    
  end
end
