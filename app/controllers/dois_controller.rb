class DoisController < ApplicationController
  include Doiable

  prepend_before_action :authenticate_user_with_basic_auth!

  def index
    response = DoisController.get_dois(username: username, password: password)

    render plain: response.body["data"], status: :ok
  end

  def show
    doi = validate_doi(params[:id])
    fail AbstractController::ActionNotFound unless doi.present?

    response = DoisController.get_doi(doi, username: username, password: password)

    render plain: response.body["data"], status: :ok
  end

  def update
    doi = validate_doi(params[:id])
    fail AbstractController::ActionNotFound unless doi.present?

    response = DoisController.put_doi(doi, username: username, password: password)

    render plain: response.body["data"], status: :ok
  end
end