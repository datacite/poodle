class MetadataController < ApplicationController
  include Metadatable

  prepend_before_action :authenticate_user_with_basic_auth!
  before_action :set_doi, except: [:create]
  before_action :set_metadata, only: [:show, :destroy]

  def index
    response = MetadataController.get_metadata(@doi, username: username, password: password)

    if response.body["data"].present?
      render xml: response.body["data"], status: :ok
    else
      render plain: "DOI is unknown to MDS", status: :not_found
    end
  end

  def create
    @doi = validate_doi(params[:doi_id])
    response = MetadataController.create_metadata(@doi, data: safe_params[:data], username: username, password: password)

    if response.status == 201
      render plain: response.body.dig("data").inspect, status: :created
    else
      render plain: "DOI is unknown to MDS", status: :not_found
    end
  end

  def destroy
    response = MetadataController.delete_metadata(@doi, username: username, password: password)

    render xml: response.body["data"], status: :ok
  end

  protected

  def set_doi
    @doi = validate_doi(params[:doi_id])
    fail AbstractController::ActionNotFound unless @doi.present?
  end

  def set_metadata
    @id = params[:id]
    fail ActiveRecord::RecordNotFound unless @id.present?
  end

  private

  def safe_params
    params.permit(:id, :doi_id).merge(data: request.raw_post)
  end
end