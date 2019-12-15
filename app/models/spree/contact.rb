module Spree
  class Contact
    include ActiveModel::Model
    include ActiveModel::Serializers::JSON

    attr_accessor :name, :email, :message, :created_at

    validates :name, :email, :message, presence: true
    validate :check_mail_formatting

    # noinspection RubyStringKeysInHashInspection
    def attributes
      {'name' => nil, 'email' => nil, 'message' => nil}
    end

    protected

    def check_mail_formatting
      return false if (self.email.nil? or self.name.nil?)
      !(self.email.match?(/[\r\n]/) || self.name.match?(/[\r\n]/))
    end
  end
end