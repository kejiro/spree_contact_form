describe 'Contact Form', type: :feature do
  before do
    visit spree.contact_path
  end

  after do
    # Do nothing
  end

  it 'should contain the title' do
    expect(page).to have_text 'Contact us'
  end
end