class ImporterController < ApplicationController
  protect_from_forgery with: :null_session
  def index
    byebug
    api_key = Rails.configuration.x.api['api_key']
    decoded_token = JWT.decode params[:data], api_key, true, :algorithm => 'HS256'
    data_json = decoded_token.first['data']
    data = ActiveSupport::JSON.decode(data_json);
    #render :json => data

    con = Mysql2::Client.new (:host => "localhost", :username => "root", :password => "radiocampus")
    con.select_db "RCG"
    #rs = con.query("Select title from CART where number = 210660")
    #rs.first

    #création de cartouche - cut - fichier mp3

    con.close

  end
end
