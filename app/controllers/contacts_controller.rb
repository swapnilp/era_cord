class ContactsController < ApplicationController

  def create
    contact = Contact.new(contact_params)
    if contact.save
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  private
  
  def contact_params
    params.require(:contact).permit(:name, :email, :mobile, :reason, :quote)
  end

  
end
