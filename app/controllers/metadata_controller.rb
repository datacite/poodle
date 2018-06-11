class MetadataController < ApplicationController
  include Metadatable

  prepend_before_action :authenticate_user_with_basic_auth!

  def show
    doi = validate_doi(params[:id])
    fail AbstractController::ActionNotFound unless doi.present?

    response = MetadataController.get_metadata(doi, username: username, password: password)

    render xml: response.body["data"], status: :ok
  end

  def create
    response = MetadataController.create_metadata(doi, username: username, password: password)

    render xml: response.body["data"], status: :ok
  end

  def destroy
    doi = validate_doi(params[:id])
    fail AbstractController::ActionNotFound unless doi.present?

    response = MetadataController.delete_metadata(doi, username: username, password: password)

    render xml: response.body["data"], status: :ok
  end

  private

  def safe_params
    params.permit(:id).merge(request.raw_post)
  end
end