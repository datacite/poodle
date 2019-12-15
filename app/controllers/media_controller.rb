class MediaController < ApplicationController
  include Mediable

  prepend_before_action :authenticate_user_with_basic_auth!
  before_action :set_doi
  before_action :set_media, only: [:show, :destroy]

  def index
    response = MediaController.list_media(@doi, username: username, password: password)

    if response.status == 200 && response.body["data"].present?
      render plain: response.body["data"], status: :ok
    elsif response.status == 200
      render plain: "No media for the DOI", status: :not_found
    elsif response.status == 401
      response.headers.delete_if { |key| key == 'X-Credential-Username' }
      render plain: "Bad credentials", status: :unauthorized
    elsif response.status == 403
      render plain: "Access is denied", status: :forbidden 
    elsif response.status == 404
      render plain: "DOI is unknown to MDS", status: :not_found 
    else
      error = response.body.dig("errors", 0, "title")
      logger.error error
      render plain: error, status: response.status
    end
  end

  def show
    response = MediaController.get_media(@doi, @id, username: username, password: password)

    if response.status == 200
      render plain: response.body["data"], status: :ok
    elsif response.status == 401
      response.headers.delete_if { |key| key == 'X-Credential-Username' }
      render plain: "Bad credentials", status: :unauthorized
    elsif response.status == 403
      render plain: "Access is denied", status: :forbidden 
    elsif response.status == 404
      render plain: "No media for the DOI", status: :not_found 
    else
      error = response.body.dig("errors", 0, "title")
      logger.error error
      render plain: error, status: response.status
    end
  end

  def create
    response = MediaController.create_media(@doi, data: safe_params[:data], username: username, password: password)

    if [200, 201].include?(response.status)
      render plain: "OK", status: :ok
    elsif response.status == 401
      response.headers.delete_if { |key| key == 'X-Credential-Username' }
      render plain: "Bad credentials", status: :unauthorized
    elsif response.status == 403
      render plain: "Access is denied", status: :forbidden 
    elsif response.status == 404
      render plain: "No media for the DOI", status: :not_found 
    else
      error = response.body.dig("errors", 0, "title")
      logger.error error
      render plain: error, status: response.status
    end
  end

  def destroy
    response = MediaController.delete_media(@doi, @id, username: username, password: password)

    if response.status == 204
      render plain: "OK", status: :ok
    elsif response.status == 401
      response.headers.delete_if { |key| key == 'X-Credential-Username' }
      render plain: "Bad credentials", status: :unauthorized
    elsif response.status == 403
      render plain: "Access is denied", status: :forbidden 
    elsif response.status == 404
      render plain: "No media for the DOI", status: :not_found 
    else
      error = response.body.dig("errors", 0, "title")
      logger.error error
      render plain: error, status: response.status
    end
  end

  protected

  def set_doi
    @doi = validate_doi(params[:doi_id])
    fail AbstractController::ActionNotFound unless @doi.present?
  end

  def set_media
    @id = params[:id]
    fail AbstractController::ActionNotFound unless @id.present?
  end

  private

  def safe_params
    params.permit(:id, :doi_id, "testMode").merge(data: request.raw_post)
  end
end