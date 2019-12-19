class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  include Bolognese::DoiUtils
  include Bolognese::Utils

  attr_accessor :username, :password

  before_action :set_raven_context
  after_action :set_consumer_header

  # check that username and password exist
  # store them in instance variables used for calling MDS API
  def authenticate_user_with_basic_auth!
    @username, @password = ActionController::HttpAuthentication::Basic::user_name_and_password(request)

    request_http_basic_authentication(realm = ENV['REALM'], message = "An Authentication object was not found in the SecurityContext") unless @username.present? && @password.present?
  end

  def set_consumer_header
    if username
      response.headers['X-Credential-Username'] = username
    else
      response.headers['X-Anonymous-Consumer'] = true
    end
  end

  def route_not_found
    render plain: "Resource not found", status: :not_found
  end

  def mds_url
    Rails.env.production? ? 'https://mds.datacite.org' : 'https://mds.test.datacite.org'
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
        response.headers['WWW-Authenticate'] = Basic realm="#{ENV['REALM']}"
        response.headers.delete_if { |key| key == 'X-Credential-Username' }
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
        ip_address: request.ip
      )
    else
      Raven.user_context(
        ip_address: request.ip
      ) 
    end
  end
end
