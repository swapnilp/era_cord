class OrganisationMailer < ActionMailer::Base
  default from: "swapnil.patil04@gmail.com"
  
  def registation_user(organisation)
    @organisation = organisation
    mail(to: @organisation.email, subject: 'Welcome to EraCord- Registation you organisation')
  end
  
end

