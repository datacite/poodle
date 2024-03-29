Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Logstash.new
  config.lograge.logger = LogStashLogger.new(type: :stdout)
  config.lograge.log_level = ENV["LOG_LEVEL"].to_sym

  config.lograge.ignore_actions = ["HeartbeatController#index", "ApplicationController#route_not_found"]
  config.lograge.ignore_custom = lambda do |event|
    event.payload.inspect.length > 100000
  end
  config.lograge.base_controller_class = "ActionController::API"

  config.lograge.custom_options = lambda do |event|
    exceptions = %w(controller action format id)
    {
      params: event.payload[:params].except(*exceptions),
      data: event.payload[:data],
      uid: event.payload[:uid],
    }
  end
end
