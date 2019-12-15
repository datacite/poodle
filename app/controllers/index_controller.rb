class IndexController < ApplicationController
  def login
    fail NotImplementedError, "one-time login and session cookies not supported by this service" 
  end

  def routing_error
    fail AbstractController::ActionNotFound
  end
end
