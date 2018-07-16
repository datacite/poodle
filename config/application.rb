require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "action_controller/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# load ENV variables from .env file if it exists
env_file = File.expand_path("../../.env", __FILE__)
if File.exist?(env_file)
  require 'dotenv'
  Dotenv.load! env_file
end

# load ENV variables from container environment if json file exists
# see https://github.com/phusion/baseimage-docker#envvar_dumps
env_json_file = "/etc/container_environment.json"
if File.exist?(env_json_file)
  env_vars = JSON.parse(File.read(env_json_file))
  env_vars.each { |k, v| ENV[k] = v }
end

# default values for some ENV variables
ENV['APPLICATION'] ||= "mds"
ENV['HOSTNAME'] ||= "mds.local"
ENV['APP_URL'] ||= "https://app.test.datacite.org"
ENV['REALM'] ||= "mds.test.datacite.org"
ENV['MEMCACHE_SERVERS'] ||= "memcached:11211"
ENV['SITE_TITLE'] ||= "MDS API"
ENV['LOG_LEVEL'] ||= "info"
ENV['TRUSTED_IP'] ||= "10.0.90.1"

module Poodle
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # secret_key_base is not used by Rails API, as there are no sessions
    config.secret_key_base = 'blipblapblup'

    # configure caching
    config.cache_store = :dalli_store, nil, { :namespace => ENV['APPLICATION'] }

    # raise error with unpermitted parameters
    config.action_controller.action_on_unpermitted_parameters = :raise

    # make sure all input is UTF-8
    config.middleware.insert 0, Rack::UTF8Sanitizer, additional_content_types: ['application/vnd.api+json', 'application/xml']

    # compress responses with deflate or gzip
    config.middleware.use Rack::Deflater
  end
end
