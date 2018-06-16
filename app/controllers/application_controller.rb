class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  include Bolognese::DoiUtils
  include Bolognese::Utils

  attr_accessor :username, :password

  after_action :set_consumer_header

  # check that username and password exist
  # store them in instance variables used for calling MDS API
  def authenticate_user_with_basic_auth!
    @username, @password = ActionController::HttpAuthentication::Basic::user_name_and_password(request)

    request_http_basic_authentication(realm = ENV['REALM']) unless @username.present? && @password.present?
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
        message = "Bad credentials"
      else
        message = exception.message
      end

      Rails.logger.debug "[#{status}]: " + message

      render plain: message, status: status
    end
  end
end
