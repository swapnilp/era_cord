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

  def roll_number_json(options= {})
    options.merge({
                    id: id,
                    student_id: student_id,
                    student: student.name,
                    roll_number: roll_number
                  })
  end
  
  def verify_student_json(options = {})
    options.merge({
                    id: id,
                    student_id: student_id,
                    name: student.name,
                    p_mobile: student.p_mobile,
                    is_duplicate: is_duplicate,
                    duplicate_field: duplicate_field,
                    is_duplicate_accepted: is_duplicate_accepted
                  })
  end
  
  
end
