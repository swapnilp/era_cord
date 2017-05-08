PublicActivity::Activity.class_eval do
  #attr_accessible :custom_field
  
  acts_as_organisation
  
  def json(options= {})
    options.merge({
                    id: id,
                    trackable_id: trackable_id,
                    trackable_type: trackable_type,
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
    else
      return "Undefined"
    end
    
  end
end


