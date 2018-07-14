class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  include Bolognese::DoiUtils
  include Bolognese::Utils

  attr_accessor :username, :password

  before_bugsnag_notify :add_user_info_to_bugsnag

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

  def routing_error
    fail AbstractController::ActionNotFound
  end

  unless Rails.env.development?
    rescue_from *(RESCUABLE_EXCEPTIONS) do |exception|
      status = case exception.class.to_s
               when "CanCan::AccessDenied", "JWT::DecodeError" then 401
               when "AbstractController::ActionNotFound", "ActionController::RoutingError" then 404
               when "ActiveModel::ForbiddenAttributesError", "ActionController::UnpermittedParameters", "NoMethodError" then 422
               when "IdentifierError" then 400
               else 400
               end

      if status == 404
        message = "bad request - no such identifier"
        status = 400
      elsif status == 401
        response.headers['WWW-Authenticate'] = ENV['REALM']
        response.headers['X-Anonymous-Consumer'] = true
        response.headers.delete_if { |key| key == 'X-Credential-Username' }
        message = "Bad credentials"
      else
        Bugsnag.notify(exception)
        
        message = exception.message
      end

      Rails.logger.debug "[#{status}]: " + message

      render plain: message, status: status
    end
  end

  def append_info_to_payload(payload)
    super
    payload[:uid] = username.downcase if username.present?
    payload[:data] = request.raw_post if request.raw_post.present?
  end

  def add_user_info_to_bugsnag(report)
    return nil unless username.present?
    
    report.user = {
      id: username.downcase
    }
  end
end
