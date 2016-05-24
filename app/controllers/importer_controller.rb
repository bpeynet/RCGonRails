class ImporterController < ApplicationController
  protect_from_forgery with: :null_session
  HMAC_SECRET = 'secret_key'
  def index
    decoded_token = JWT.decode params[:token], ImporterController::HMAC_SECRET, true, { :algorithm => 'HS256' }
    data = decoded_token.first

    render :json => data
  end
end
