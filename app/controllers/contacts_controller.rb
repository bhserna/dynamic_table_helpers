class ContactsController < ApplicationController
  def index
    @contacts = Contact.search(params[:search])
  end
end
