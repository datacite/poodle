class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include ApiAuthenticatable

  include Bolognese::DoiUtils
  include Bolognese::Utils

  attr_accessor :username, :password, :bearer

  before_action :set_raven_context
  after_action :set_consumer_header

  # check that Basic or Bearer credentials exist
  # store them in instance variables used for calling DataCite API
  def authenticate_request!
    @bearer = bearer_token_from_request
    return if @bearer.present?

    @username, @password = basic_credentials_from_request
    return if @username.present? && @password.present?

    request_http_basic_authentication(ENV["REALM"], "An Authentication object was not found in the SecurityContext")
  end

  def set_consumer_header
    if username
      response.headers["X-Credential-Username"] = username
    else
      response.headers["X-Anonymous-Consumer"] = true
    end
  end

  def route_not_found
    render plain: "Resource not found", status: :not_found
  end

  unless Rails.env.development?
    rescue_from *(RESCUABLE_EXCEPTIONS) do |exception|
      status = case exception.class.to_s
               when "CanCan::AuthorizationNotPerformed", "JWT::DecodeError", "JWT::VerificationError" then 401
               when "CanCan::AccessDenied" then 403
               when "ActionController::RoutingError", "AbstractController::ActionNotFound" then 404
               when "ActiveModel::ForbiddenAttributesError", "ActionController::UnpermittedParameters", "NoMethodError" then 422
               when "NotImplementedError" then 501
               when "IdentifierError" then 400
               else 400
               end

      if status == 401
        response.headers["WWW-Authenticate"] = "Basic realm=\"#{ENV['REALM']}\", Bearer realm=\"#{ENV['REALM']}\""
        response.headers.delete_if { |key| key == "X-Credential-Username" }
        message = "Bad credentials"
      elsif status == 403
        message = "Access is denied"
      elsif status == 404
        message = "DOI not found"
      elsif status == 501
        message = "Not Implemented"
      else
        # send error to sentry unless it is an identifier error
        Raven.capture_exception(exception) unless exception.class.to_s == "IdentifierError"

        message = exception.message
      end

      logger.error "[#{status}]: #{message}"

      render plain: message, status: status
    end
  end

  def append_info_to_payload(payload)
    super
    payload[:uid] = username.downcase if username.present?
    payload[:data] = Base64.strict_encode64(request.raw_post) if request.raw_post.present?
  end

  def set_raven_context
    if username.present?
      Raven.user_context(
        id: username.downcase,
        ip_address: request.ip,
      )
    else
      Raven.user_context(
        ip_address: request.ip,
      )
    end
  end

  private

  def bearer_token_from_request
    auth_header = request.authorization.to_s
    return nil unless auth_header.match?(/\ABearer\s+/i)

    auth_header.sub(/\ABearer\s+/i, "").strip.presence
  end

  def basic_credentials_from_request
    auth_header = request.authorization.to_s
    return ActionController::HttpAuthentication::Basic::user_name_and_password(request) unless auth_header.match?(/\ABasic\s+/i)
    return ActionController::HttpAuthentication::Basic::user_name_and_password(request) if auth_header.start_with?("Basic ")

    raw_credentials = auth_header.sub(/\ABasic\s+/i, "").strip
    decoded = Base64.decode64(raw_credentials)
    decoded.split(":", 2)
  end
end
