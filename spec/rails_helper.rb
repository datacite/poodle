# set ENV variables for testing
ENV["RAILS_ENV"] = "test"

require 'bundler/setup'
Bundler.setup

require 'simplecov'
SimpleCov.start

require File.expand_path("../../config/environment", __FILE__)
require "rspec/rails"
require "capybara/rspec"
require "capybara/rails"
require "webmock/rspec"
require "rack/test"
require "maremma"

WebMock.disable_net_connect!(
  allow: ['codeclimate.com:443', ENV['PRIVATE_IP'], ENV['HOSTNAME']],
  allow_localhost: true
)

VCR.configure do |c|
  mds_token = Base64.strict_encode64("#{ENV['MDS_USERNAME']}:#{ENV['MDS_PASSWORD']}")

  c.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  c.hook_into :webmock
  c.ignore_localhost = true
  c.ignore_hosts "codeclimate.com"
  # c.ignore_request { |request| URI(request.uri).path.start_with("shoulder") }
  c.filter_sensitive_data("<MDS_TOKEN>") { mds_token }
  c.configure_rspec_metadata!
end

RSpec.configure do |config|
  # config.include WebMock::API
  config.include Rack::Test::Methods, :type => :api
  config.include Rack::Test::Methods, :type => :request
  config.include Rack::Test::Methods, :type => :controller

  def app
    Rails.application
  end
end
