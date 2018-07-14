class MetadataController < ApplicationController
  include Metadatable

  prepend_before_action :authenticate_user_with_basic_auth!
  before_action :set_doi, only: [:destroy]

  before_bugsnag_notify :add_metadata_to_bugsnag

  def index
    #return head :no_content unless params[:doi_id].present?

    @doi = validate_doi(params[:doi_id])

    response = MetadataController.get_metadata(@doi, username: username, password: password)

    if response.status == 200
      render xml: response.body["data"], status: :ok
    elsif response.status == 401
      render plain: "Bad credentials", status: :unauthorized
    elsif response.status == 403
      render plain: "Access is denied", status: :forbidden 
    elsif response.status == 404
      render plain: "DOI is unknown to MDS", status: :not_found 
    else
      render plain: response.body.dig("errors", 0, "title"), status: response.status
    end
  end

  def create
    # find or generate doi
    @doi = MetadataController.extract_doi(params[:doi_id], data: safe_params[:data], number: safe_params[:number])
    fail AbstractController::ActionNotFound unless @doi.present?

    response = MetadataController.create_metadata(@doi, data: safe_params[:data], username: username, password: password)

    if [200, 201].include?(response.status)
      render plain: "OK (" + response.body.dig("data", "id").upcase + ")", status: :created
    elsif response.status == 401
      render plain: "Bad credentials", status: :unauthorized
    elsif response.status == 403
      render plain: "Access is denied", status: :forbidden 
    elsif response.status == 422
      render plain: response.body.dig("errors", 0, "title"), status: :bad_request
    else
      render plain: response.body.dig("errors", 0, "title"), status: response.status
    end
  end

  def destroy
    response = MetadataController.delete_metadata(@doi, username: username, password: password)

    if response.status == 200
      render plain: "OK", status: :ok
    elsif response.status == 401
      render plain: "Bad credentials", status: :unauthorized
    elsif response.status == 403
      render plain: "Access is denied", status: :forbidden 
    else
      render plain: response.body.dig("errors", 0, "title"), status: response.status
    end
  end

  protected

  def set_doi
    @doi = validate_doi(params[:doi_id])
    fail AbstractController::ActionNotFound unless @doi.present?
  end

  private

  def safe_params
    params.permit(:id, :doi_id, :number, "testMode").merge(data: request.raw_post)
  end

  def add_metadata_to_bugsnag(report)
    return nil unless params.fetch(:data, nil).present?

    report.add_tab(:metadata, {
      metadata: params.fetch(:data)
    })
  end
end