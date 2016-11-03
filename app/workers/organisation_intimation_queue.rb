class OrganisationIntimationQueue < Struct.new(:organisation)
  #@queue = :mailer
  
  def perform
    send_mails(organisation)
  end

  def send_mails(organisation)
    OrganisationMailer.intimate_user(organisation).deliver
  end

end
