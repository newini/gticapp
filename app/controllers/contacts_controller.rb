class ContactsController < ApplicationController
  # reCAPTCHA
  # See, https://github.com/heartcombo/devise/wiki/How-To:-Use-Recaptcha-with-Devise
  prepend_before_action :check_captcha, only: [:create] # Change this to be any actions you want to protect.


  def index
    @contacts = Contact.paginate(page: params[:page]).order(created_at: :desc)
  end

  def create
    @contact = Contact.new(contact_params)

    if @contact.save
      # Send auto reply mail to user
      NoReplyMailer.contact_autoreply(@contact).deliver
      # Send notify mails to active staffs
      NoReplyMailer.contact_notify(@contact).deliver
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

    # reCAPTCHA
    def check_captcha
      unless verify_recaptcha
        #self.resource = resource_class.new contact_params
        #respond_with_navigational(resource) { render :new }
        redirect_to contact_us_path(contact: contact_params)
      end
    end


end
