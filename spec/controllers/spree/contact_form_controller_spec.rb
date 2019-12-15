RSpec.describe Spree::ContactFormController, type: :controller do
  before do
    allow(controller).to receive(:spree_current_user) { nil }
  end
  it 'should show the form' do
    expect(get :show).to render_template :show
  end

  context '#update' do
    context 'when passed incorrect parameters' do
      it 'should show the form' do
        expect(put :update, params: {contact: {name: nil}}).to render_template :show
      end
      it 'should not call the Mailer' do
        expect(SpreeContactForm::Mailer).not_to receive(:contact_mail)
        put :update, params: {contact: {name: ''}}
      end
    end

    context 'when passed with all required parameters' do
      let(:params) { {contact: {email: 'john@example.com', name: 'John Doe', message: 'A simple message'}} }
      let(:spam_service) { instance_double(SpreeContactForm::SpamService) }
      let(:log_service) { instance_double(SpreeContactForm::LogService) }

      before do
        allow(SpreeContactForm::SpamService).to receive(:new).and_return(spam_service)
        allow(SpreeContactForm::LogService).to receive(:new).and_return(log_service)
      end

      context 'and the message is not spam' do

        before do
          expect(spam_service).to receive(:call).and_return(Spree::ServiceModule::Result.new(true, nil, nil))
          allow(log_service).to receive(:call)
          allow(SpreeContactForm::Mailer).to receive_message_chain('with.contact_mail.deliver')
        end

        it 'should redirect to the form' do
          expect(put :update, params: params).to redirect_to spree.contact_url(only_path: true)
        end

        it 'should call the log service' do
          expect(log_service).to receive(:call)
          put :update, params: params
        end

        it 'should call the mailer' do
          expect(SpreeContactForm::Mailer).to receive_message_chain('with.contact_mail.deliver')
          put :update, params: params
        end
      end

      context 'and the message is spam' do
        let(:spam_result) { Spree::ServiceModule::Result.new(false, {spam: true}, nil) }

        before do
          expect(spam_service).to receive(:call).and_return(spam_result)
          allow(log_service).to receive(:call)
        end

        it 'should return a bad request error' do
          expect(put :update, params: params).to have_attributes(status: 400)
        end

        it 'should call the log service' do
          expect(log_service).to receive(:call).with(hash_including(spam_result: spam_result))
          put :update, params: params
        end

        it 'should not call the mailer' do
          expect(SpreeContactForm::Mailer).not_to receive('with')
          put :update, params: params
        end
      end
    end
  end

end
