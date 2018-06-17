class MetadataController < ApplicationController
  include Metadatable

  prepend_before_action :authenticate_user_with_basic_auth!
  before_action :set_doi, except: [:create]

  def index
    response = MetadataController.get_metadata(@doi, username: username, password: password)

    if response.status == 200
      render xml: response.body["data"], status: :ok
    else
      render plain: "DOI is unknown to MDS", status: :not_found
    end
  end

  def create
    # find or generate doi
    @doi = MetadataController.extract_doi(params[:doi_id], data: safe_params[:data], number: safe_params[:number])
    fail AbstractController::ActionNotFound unless @doi.present?

    response = MetadataController.create_metadata(@doi, data: safe_params[:data], username: username, password: password)

    if response.status == 201
      render plain: "OK (" + response.body.dig("data", "id").upcase + ")", status: :created
    elsif response.status == 200
      render plain: "OK (" + response.body.dig("data", "id").upcase + ")", status: :ok
    else
      render plain: "DOI is unknown to MDS", status: :not_found
    end
  end

  def destroy
    response = MetadataController.delete_metadata(@doi, username: username, password: password)

    if response.status == 200
      render plain: "OK", status: :ok
    else
      render plain: response.body.inspect, status: :ok
    end
  end

  protected

  def set_doi
    @doi = validate_doi(params[:doi_id])
    fail AbstractController::ActionNotFound unless @doi.present?
  end

  private

  def safe_params
    params.permit(:id, :doi_id, :number).merge(data: request.raw_post)
  end
end