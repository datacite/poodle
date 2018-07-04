class DoisController < ApplicationController
  include Doiable

  prepend_before_action :authenticate_user_with_basic_auth!
  before_action :set_doi, only: [:show, :destroy]

  def index
    response = DoisController.get_dois(username: username, password: password)

    if response.body["data"].present?
      render plain: response.body.dig("data", "dois").join("\n"), status: :ok
    elsif response.status == 204
      head :no_content
    else
      render plain: response.body.dig("errors", 0, "title"), status: response.status
    end
  end

  def show
    response = DoisController.get_doi(@doi, username: username, password: password)

    if response.body["data"].present?
      render plain: response.body.dig("data", "url"), status: :ok
    else
      render plain: "DOI not found", status: :not_found
    end
  end

  def update
    # Rails.logger.info safe_params.inspect
    return head :bad_request unless safe_params[:data].present?

    doi, url = DoisController.extract_url(doi: validate_doi(params[:id]), data: safe_params[:data])

    response = DoisController.put_doi(doi, url: url, username: username, password: password)

    if [200, 201].include?(response.status)
      render plain: response.body.dig("data", "attributes", "url"), status: :created
    elsif response.status == 404
      render plain: "DOI not found", status: :not_found
    else
      render plain: response.body.dig("errors", 0, "title"), status: response.status
    end
  end

  def destroy
    response = DoisController.delete_doi(@doi, username: username, password: password)

    if response.status == 204
      render plain: "OK", status: :ok
    elsif response.status == 404
      render plain: "DOI not found", status: :not_found
    else
      render plain: response.body.dig("errors", 0, "title"), status: response.status
    end
  end

  protected

  def set_doi
    @doi = validate_doi(params[:id])
    fail AbstractController::ActionNotFound unless @doi.present?
  end

  private

  def safe_params
    params.permit(:id, :doi).merge(data: request.raw_post)
  end
end