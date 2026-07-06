module ApiAuthenticatable
  extend ActiveSupport::Concern

  class_methods do
    def api_key_username?(username)
      username.present? && username.length > 20 && username.match?(/\ADC\./i)
    end

    def maremma_auth(options = {})
      return { bearer: options[:bearer] } if options[:bearer].present?

      username = options[:username]
      password = options[:password]
      if username.present? && (password.present? || api_key_username?(username))
        return { username: username, password: password.to_s }
      end

      nil
    end

    def missing_auth_response
      OpenStruct.new(body: { "errors" => [{ "title" => "Authentication credentials missing" }] })
    end

    def with_maremma_auth(options = {})
      auth = maremma_auth(options)
      return missing_auth_response if auth.blank?

      yield auth
    end

    def client_relationship(auth)
      return nil unless auth.key?(:username)
      return nil if api_key_username?(auth[:username])

      {
        "client" => {
          "data" => {
            "type" => "clients",
            "id" => auth[:username],
          },
        },
      }
    end
  end

  def forward_auth_options
    self.class.maremma_auth(bearer: bearer, username: username, password: password)
  end
end