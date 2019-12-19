class IndexController < ApplicationController
  def login
    render plain: "One-time login and session cookies not supported by this service", status: :not_implemented
  end

  def routing_error
    fail AbstractController::ActionNotFound
  end
end
