PublicActivity::Activity.class_eval do
  #attr_accessible :custom_field
  
  acts_as_organisation
  
  def json(options= {})
    options.merge({
                    id: id,
                    trackable_id: trackable_id,
                    trackable_type: trackable_type,
                    name: trackable.try(:name),
                    owner: owner.try(:email),
                    owner_type: owner_type,
                    key: activity_desc,
                    recipient: recipient.try(:name),
                    recipient_type: recipient_type,
                    date: created_at.strftime("%d-%b-%Y @ %I:%M %p"),
                    owner_mobile: owner.try(:mobile),
                    parameters: parameters
                  })
  end
  
  def activity_desc
    if key == "exam.created"
      return "Exam Created"
    elsif key == "exam.update"
      return "Exam Updated"
    elsif key == "exam.verify"
      return "Exam Verified"
    elsif key == "exam.conduct"
      return "Exam Conducted"
    elsif key == "exam.verify_absenty"
      return "Exam absentee verified"
    elsif key == "exam.verify_result"
      return "Exam Verify Result"
    elsif key == "exam.publish"
      return "Exam Published"
    elsif key == "jkci_class.toggle_class_sms"
      return "Toggle Class Sms"
    elsif key == "jkci_class.toggle_exam_sms"
      return "Toggle Class Exam Sms"
    elsif key == "jkci_class.remove_students"
      return "Removed class students"
    elsif key == "jkci_class.manage_student_subject"
      return "Save student subjects"
    elsif key == "jkci_class.manage_roll_number"
      return "Save student roll numbers"
    elsif key == "jkci_class.upgrade_batch"
      return "Upgrade Class"
    elsif key == "jkci_class.verify_student"
      return "Verify student"
    elsif key == "jkci_class.make_active"
      return "Make Class Active"
    elsif key == "jkci_class.make_deactive"
      return "Make Class Deactive"
    elsif key == "jkci_class.create_time_table_class"
      return "Create Class timetable class"
    elsif key == "jkci_class.update_time_table_class"
      return "Update Class timetable class"
    elsif key == "jkci_class.destroy_time_table_class"
      return "Destroy Class timetable class"
    elsif key == "jkci_class.assign_time_table_class_teacher"
      return "Assign Teacher To Class timetable class"
    else
      return "Undefined"
    end
    
  end
end


