Spree::Core::Engine.add_routes do
  resource :contact, only: [:show, :update], controller: 'contact_form'
  # Add your extension routes here
end
