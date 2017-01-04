class HomeController < ApplicationController
  layout "application"
  skip_before_filter :authenticate_with_token!, only: [:index, :mobile, :terms_of_service, :presentation]

  def index
  end

  def mobile
  end

  def terms_of_service
    render layout: "terms"
  end

  def presentation
    render layout: "presentation"
  end

  def new_organisation
    @org  = Organisation.new
  end

  def create_organisation
    @org  = Organisation.new(organisation_params)
    users = User.where(email: @org.try(:email))
    if users.present? && users.map(&:organisation).map(&:root?).include?(true)
      redirect_to new_organisation_path , flash: {success: false, notice: "Email Already used for organisation Please try with another email."} 
      return
    end
    if @org.save 
      redirect_to root_path
    else
      @org.send_generated_code if @org.errors[:email].include?(' allready registered. Please check email')
      render :new
    end
  end
  
end
