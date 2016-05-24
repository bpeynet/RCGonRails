class ImporterController < ApplicationController
  protect_from_forgery with: :null_session
  HMAC_SECRET = 'secret_key'
  def index
    decoded_token = JWT.decode token, ImporterController::HMAC_SECRET, :algorithm => 'HS256'
    data = decoded_token.first

    render :json => data
  end
end
