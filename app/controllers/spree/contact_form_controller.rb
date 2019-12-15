module Spree
  class ContactFormController < StoreController
    respond_to :html

    def permitted_attributes
      [:email, :name, :message, :url]
    end

    def show
      @contact = Spree::Contact.new
    end

    def update
      @contact = Spree::Contact.new(params.require(:contact).permit(permitted_attributes))
      if @contact.valid?
        SpreeContactForm::SpamService.call(contact: @contact, req: request) do |result|
          SpreeContactForm::LogService.call(contact: @contact, req: request, spam_result: result)
          if result.success?
            SpreeContactForm::Mailer.with(contact: @contact).contact_mail.deliver
            redirect_to contact_url, notice: 'Your message has been sent'
          else
            render plain: 'Message not sent, marked as spam', status: 400
          end
        end
      else
        render action: 'show'
      end
    end
  end
end
