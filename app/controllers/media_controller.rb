class MediaController < ApplicationController
  include Mediable

  prepend_before_action :authenticate_user_with_basic_auth!
  before_action :set_doi
  before_action :set_media, only: [:show, :destroy]

  def index
    response = MediaController.list_media(@doi, username: username, password: password)

    if response.body["errors"].present?
      render plain: "DOI is unknown to MDS", status: :not_found
    elsif response.body["data"].present?
      render plain: response.body["data"], status: :ok
    else
      render plain: "No media for the DOI", status: :not_found
    end
  end

  def show
    response = MediaController.get_media(@doi, @id, username: username, password: password)

    if response.body["data"].present?
      render plain: response.body["data"], status: :ok
    else
      render plain: "No media for the DOI", status: :not_found
    end
  end

  def create
    response = MediaController.create_media(@doi, data: safe_params[:data], username: username, password: password)

    if response.body["data"].present?
      render plain: "OK", status: :ok
    else
      render plain: "No media for the DOI", status: :not_found
    end
  end

  def destroy
    response = MediaController.delete_media(@doi, @id, username: username, password: password)

    if response.status == 204
      render plain: "OK", status: :ok
    else

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
    params.permit(:id, :doi_id).merge(data: request.raw_post)
  end
end