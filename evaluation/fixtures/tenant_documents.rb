# frozen_string_literal: true

# Static Rails review fixture. Do not load as application code.
# Rails 8.1, PostgreSQL. Users belong to one account. Documents belong to an
# account; only that account's users may read or update them. Authentication
# sets current_user and current_account. There are no default scopes, policy
# callbacks, or database row-security rules beyond what is shown here.

class DocumentsController < ApplicationController
  before_action :authenticate_user!

  def show
    document = Document.find(params[:id])
    render json: document.slice(:id, :title, :body)
  end

  def update
    document = current_account.documents.find(params[:id])
    document.update!(document_params)
    render json: document.slice(:id, :title)
  end

  private

  def document_params
    params.require(:document).permit(:title, :body, :account_id)
  end
end
