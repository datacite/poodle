class MediaController < ApplicationController
  prepend_before_action :authenticate_user_with_basic_auth!
end