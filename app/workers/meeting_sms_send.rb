class MeetingSmsSend < Struct.new(:meeting)
  include SendingSms
  def perform
    send_sms(meeting)
  end
  
  def send_sms(meeting)
    #exam.exam_catlogs.includes([:student]).only_absents.each_with_index do |exam_catlog, index|
    meeting.batch.students.each_with_index do |student, index| 
      if student.enable_sms
        message = "Parent's meeting  will be conducted on #{meeting.date.strftime('%d/%m/%Y %H:%M')}.Please contact #{meeting.contact_person}. JKSai !!!"
        url = "https://www.txtguru.in/imobile/api.php?username=#{SMSUNAME}&password=#{SMSUPASSWORD}&source=JKSaiu&dmobile=#{student.sms_mobile}&message=#{message}"
        deliver_sms(URI::encode(url))
        SmsSent.new({number: index, obj_type: "parent_meeting", obj_id: meeting.id, message: message, is_parent: true, organisation_id: student.organisation_id}).save
      end
    end
  end
end
#Delayed::Job.enqueue MeetingSmsSend.new(ParentsMeeting.last)
  
