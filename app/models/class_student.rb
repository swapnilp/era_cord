class ClassStudent < ActiveRecord::Base
  belongs_to :jkci_class
  belongs_to :student
  
  default_scope { where(organisation_id: Organisation.current_id) }
  
  def add_sub_class(sub_class_id)
    sub_classes = self.sub_class.split(',').map(&:to_i)
    sub_classes << sub_class_id
    self.update_attributes({sub_class: ",#{sub_classes.uniq.join(',')},"})
  end

  def remove_sub_class(sub_class_id)
    sub_classes = self.sub_class.split(',').map(&:to_i)
    sub_classes.delete(sub_class_id)
    self.update_attributes({sub_class: ",#{sub_classes.uniq.join(',')},"})
  end

  def subject_json(options= {})
    options.merge({
                    id: id,
                    student_id: student_id, 
                    roll_number: roll_number,
                    name: student.name,
                    o_subjects: student.subjects.optional.map(&:id)
                  })
  end
end
