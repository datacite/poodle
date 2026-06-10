Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.release = "poodle:" + Poodle::Application::VERSION
  config.environment = Rails.env
  config.send_default_pii = true
end