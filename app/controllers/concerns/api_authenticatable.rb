module ApiAuthenticatable
  extend ActiveSupport::Concern

  class_methods do
    def maremma_auth(options = {})
      return { bearer: options[:bearer] } if options[:bearer].present?
      return { username: options[:username], password: options[:password] } if options[:username].present? && options[:password].present?

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