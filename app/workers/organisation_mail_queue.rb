class OrganisationMailQueue < Struct.new(:organisation)
  #@queue = :mailer
  
  def perform
    send_mails(organisation)
  end

  def send_mails(organisation)
    OrganisationMailer.registation_user(organisation).deliver
  end

end
