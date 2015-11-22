class CustomMailQueue < Struct.new(:promotional_mails)
  #@queue = :mailer
  
  def perform
    send_mails(promotional_mails)
  end

  def send_mails(promotional_mails)
    promotional_mails.mails.split(',').each do |student|
      CustomMailer.send_custom_mail(student, promotional_mails.msg).deliver
    end
  end

end
