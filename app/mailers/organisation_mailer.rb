class OrganisationMailer < ActionMailer::Base
  default from: "admin@eracord.com"
  
  def registation_user(organisation)
    @organisation = organisation
    mail(to: @organisation.email, subject: 'Welcome to EraCord- Create eraCord account')
  end

  def intimate_user(organisation)
    @organisation = organisation
    mail(to: @organisation.email, subject: 'Welcome to EraCord- Intimate eraCord account')
  end
  
end

