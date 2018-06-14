class DoisController < ApplicationController
  include Doiable

  prepend_before_action :authenticate_user_with_basic_auth!

  def index
    response = DoisController.get_dois(username: username, password: password)

    if response.body["data"].present?
      render plain: response.body.dig("data", "dois").join("\n"), status: :ok
    else
      render plain: "No DOIs found", status: :not_found
    end
  end

  def show
    doi = validate_doi(params[:id])
    fail AbstractController::ActionNotFound unless doi.present?

    response = DoisController.get_doi(doi, username: username, password: password)

    if response.body["data"].present?
      render plain: response.body.dig("data", "url"), status: :ok
    else
      render plain: "No URL found", status: :not_found
    end
  end

  def update
    doi = validate_doi(params[:id])
    fail AbstractController::ActionNotFound unless doi.present?
    fail IdentifierError, "No parameters provided" unless safe_params[:data].present?
    Rails.logger.info safe_params.inspect
    url = extract_url(doi: doi, data: safe_params[:data])

    response = DoisController.put_doi(doi, url: url, username: username, password: password)

    render plain: response.body["data"], status: :ok
  end

  private

  def safe_params
    params.permit(:id).merge(data: request.raw_post)
  end
end