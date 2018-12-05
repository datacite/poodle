class IndexController < ApplicationController
  def index
    render plain: ENV['SITE_TITLE']
  end

  def login
    redirect_to :action => "index"
    # fail NotImplementedError, "one-time login and session cookies not supported by this service" 
  end
end