class OrganisationMailer < ActionMailer::Base
  default from: "admin@eracord.com"
  
  def registation_user(organisation)
    @organisation = organisation
    mail(to: @organisation.email, subject: 'Welcome to EraCord- Create eraCord account')
  end
  
end

