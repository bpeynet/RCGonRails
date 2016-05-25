class ImporterController < ApplicationController
  protect_from_forgery with: :null_session
  HMAC_SECRET = 'secret_key'
  def index
    decoded_token = JWT.decode params[:data], ImporterController::HMAC_SECRET, true, { :algorithm => 'HS256' }
    data_json = decoded_token.first['data']
    data = ActiveSupport::JSON.decode(data_json);

    render :json => data
  end
end
