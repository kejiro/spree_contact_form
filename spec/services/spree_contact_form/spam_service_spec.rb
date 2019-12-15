RSpec.describe SpreeContactForm::SpamService, type: :service do
  subject { described_class }

  it 'should respond to call' do
    expect(SpreeContactForm::SpamService).to respond_to :call
  end

  context "called with check action" do
    let(:contact) { Spree::Contact.new(name: 'viagra-test-123', email: 'akismet-guaranteed-spam@example.com', message: 'A simple spam') }
    let(:req) { ActionDispatch::TestRequest.create }

    it 'should flag a spam correctly' do
      expect(Akismet).to receive(:spam?).with(req.ip, req.user_agent, any_args).and_return(true)
      res = subject.call(contact: contact, req: req)
      expect(res).to be_an_failure
    end

    it 'should not flag a proper contact request as spam' do
      req = ActionDispatch::TestRequest.create
      expect(Akismet).to receive(:spam?).with(req.ip, req.user_agent, any_args).and_return(false)
      res = subject.call(contact: contact, req: req)
      expect(res).to be_a_success
    end

  end

  context "correcting an incorrect flag" do
    let(:data) {
      {
          ip: "1.2.3.4",
          user_agent: "Test Request",
          params: {
              type: "contact-form",
              text: "A simple message"
          }
      }
    }

    it "should mark a spam as ham" do
      expect(Akismet).to receive(:ham).with(data[:ip], data[:user_agent], data[:params])
      res = subject.call(action: "ham", ip: data[:ip], user_agent: data[:user_agent], params: data[:params])
      expect(res).to be_a_success
    end

    it "should mark a ham as spam" do
      expect(Akismet).to receive(:spam).with(data[:ip], data[:user_agent], data[:params])
      res = subject.call(action: "spam", ip: data[:ip], user_agent: data[:user_agent], params: data[:params])
      expect(res).to be_a_success
    end


  end


end