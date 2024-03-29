class MetadataController < ApplicationController
  include Metadatable

  prepend_before_action :authenticate_user_with_basic_auth!
  before_action :set_doi, only: [:destroy]
  before_action :set_raven_context, only: [:create_metadata]

  def index
    @doi = validate_doi(params[:doi_id])
    fail AbstractController::ActionNotFound unless @doi.present?

    response = MetadataController.get_metadata(@doi, username: username, password: password)

    if response.status == 200
      render xml: response.body["data"], status: :ok
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

  def create
    if request.content_type == "application/x-www-form-urlencoded"
      render plain: "Content type application/x-www-form-urlencoded is not supported", status: :unsupported_media_type
      return
    end

    from = safe_params[:data].blank? ? "datacite" : find_from_format_by_string(safe_params[:data])

    if from.blank?
      render plain: "Metadata format not recognized", status: :unsupported_media_type
      return
    end

    # find or generate doi
    @doi = extract_doi(params[:doi_id], data: safe_params[:data], from: from, number: safe_params[:number])
    if @doi.blank?
      render plain: "DOI not found", status: :not_found
      return
    end

    response = MetadataController.create_metadata(@doi, data: safe_params[:data], username: username, password: password)

    if [200, 201].include?(response.status)
      render plain: "OK (" + response.body.dig("data", "id").upcase + ")", status: :created, location: ENV["MDS_URL"] + "/metadata/" + @doi
    elsif response.status == 401
      response.headers.delete_if { |key| key == 'X-Credential-Username' }
      render plain: "Bad credentials", status: :unauthorized
    elsif response.status == 403
      render plain: "Access is denied", status: :forbidden
    else
      error = response.body.dig("errors", 0, "title")
      logger.error error
      render plain: error, status: response.status
    end
  end

  def destroy
    response = MetadataController.delete_metadata(@doi, username: username, password: password)

    if response.status == 200
      render plain: "OK", status: :ok
    elsif response.status == 401
      response.headers.delete_if { |key| key == 'X-Credential-Username' }
      render plain: "Bad credentials", status: :unauthorized
    elsif response.status == 403
      render plain: "Access is denied", status: :forbidden
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

  private

  def safe_params
    params.permit(:id, :doi_id, :number, "testMode").merge(data: request.raw_post)
  end

  def set_raven_context
    return nil if params.fetch(:data, nil).blank?

    Raven.extra_context metadata: Base64.decode64(params.fetch(:data))
  end
end
