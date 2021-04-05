class ContactsController < ApplicationController

  def index
    @contacts = Contact.paginate(page: params[:page]).order(created_at: :desc)
  end

  def create
    @contact = Contact.new(contact_params)

    if @contact.save
      redirect_to contact_us_path(after_submit: true)
    else
      render 'new'
    end
  end

  def show
    @contact = Contact.find(params[:id])
    @contact.update(is_read: true)
  end

  def destroy
    @contact = Contact.find(params[:id])
    @contact.destroy
    redirect_to contacts_path , :flash => {:success => 'Deleted'}
  end

  # ================================================
  # method for member
  def update_response_completed
    @contact = Contact.find(params[:id])
    @contact.update(is_response_completed: true)
    redirect_to contact_path(@contact)
  end

  # ================================================
  private
    def contact_params
      params.fetch(:contact, {}).permit(
        :name, :category_id, :affiliation, :title, :email,
        :subject, :body
      )
    end


end
