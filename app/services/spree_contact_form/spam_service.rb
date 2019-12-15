require 'akismet'
module SpreeContactForm
  class SpamService
    prepend Spree::ServiceModule::Base

    VARS = %q{
      REQUEST_URI
      REQUEST_METHOD
      HTTP_ACCEPT
      HTTP_ACCEPT_ENCODING
      HTTP_ACCEPT_LANGUAGE
      HTTP_COOKIE
      HTTP_HOST
      HTTP_REFERER
      HTTP_USER_AGENT
      HTTP_VERSION
    }

    def call(action: "check", **args)
      case action
      when "check"
        check(args)
      when "ham"
        ham(args)
      when "spam"
        spam(args)
      else
        raise NotImplementedError
      end
    end

    private

    def check(contact:, req:, **args)
      params = {
          type: 'contact-form',
          text: contact.message,
          created_at: contact.created_at,
          author: contact.name,
          author_email: contact.email,
          referrer: req.referrer,
          env: req.env.slice(*VARS),
          test: !Rails.env.production?
      }
      is_spam = ::Akismet.spam?(req.ip, req.user_agent, params)
      if is_spam
        failure({ip: req.ip, ua: req.user_agent, params: params})
      else
        success({ip: req.ip, ua: req.user_agent, params: params})
      end
    end

    def ham(ip:, user_agent:, params:)
      ::Akismet.ham(ip, user_agent, params)
    end

    def spam(ip:, user_agent:, params:)
      ::Akismet.spam(ip, user_agent, params)
    end
  end
end