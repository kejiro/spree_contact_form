module SpreeContactForm
  class Mailer < Spree::BaseMailer
    def contact_mail
      @contact = params[:contact]

      headers['Sender'] = @contact.email
      mail(from: from_address, to: Spree::Config[:mail_contact_address], subject: 'Message from contact form')
    end
  end
end