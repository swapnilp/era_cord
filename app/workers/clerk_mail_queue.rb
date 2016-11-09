class ClerkMailQueue < Struct.new(:user_clerk)
  #@queue = :mailer
  
  def perform
    send_mails(user_clerk)
  end

  def send_mails(user_clerk)
    ClerkMailer.registation_clerk(user_clerk).deliver
  end

end
