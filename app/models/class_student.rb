class ClassStudent < ActiveRecord::Base
  belongs_to :jkci_class, counter_cache: true
  belongs_to :student

  has_many :exam_catlogs,->(class_student) { where("student_id = ? ", class_student.student_id) }, through: :jkci_class
  
  default_scope { where(organisation_id: Organisation.current_id) }
  scope :active, -> { where(deleted_at: nil) }
  
  def add_sub_class(sub_class_id)
    sub_classes = self.sub_class.present? ? self.sub_class.split(',').map(&:to_i) : [0]
    sub_classes << sub_class_id
    self.update_attributes({sub_class: ",#{sub_classes.uniq.join(',')},"})
  end

  def remaining_class_fee
    jkci_class.fee - self.collected_fee
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
                    is_duplicate_accepted: is_duplicate_accepted,
                    exams_count: exam_catlogs_count
                  })
  end

  def fee_info_json(options = {})
    options.merge({
                    id: id,
                    student_id: student_id,
                    class_id: jkci_class_id,
                    class_name: jkci_class.class_name,
                    remaining_fee: jkci_class.fee - collected_fee
                  })
  end

  def accounts_json(options = {})
    options.merge({
                    name: student.name, 
                    p_mobile: student.p_mobile,
                    jkci_class: jkci_class.try(:class_name),
                    student_id: student_id,
                    collected_fee: 0,
                    remaining_fee: jkci_class.try(:fee) || 0,
                    total_transactions: 0
                  })
  end

  def meetings_json(options = {})
    options.merge({
                    id: student_id,
                    name: student.name, 
                    p_mobile: student.p_mobile
                  })
  end

  def sync_json(options = {})
    options.merge({
                    id: id,
                    jkci_class_id: jkci_class_id,
                    student_id: student_id,
                    sub_class: sub_class
                  })
  end
  
end
