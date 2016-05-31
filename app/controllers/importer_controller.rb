class ImporterController < ApplicationController
  protect_from_forgery with: :null_session
  require 'database_connection'
  include DatabaseConnection
  def index
    api_key = Rails.configuration.x.api['api_key']
    decoded_token = JWT.decode params[:data], api_key, true, :algorithm => 'HS256'
    data_json = decoded_token.first['data']
    data = ActiveSupport::JSON.decode(data_json)
    #render :json => data

    DatabaseConnection::connect do |conn|
      #rs = conn.query("Select title from CART where number = 210660")
      #rs.first

      #création de cartouche - cut - fichier mp3
    end


  end
end
