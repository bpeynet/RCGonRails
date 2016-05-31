class ImporterController < ApplicationController
  protect_from_forgery with: :null_session
  require 'openssl'
  require 'base64'
  require 'database_connection'
  include DatabaseConnection
  before_action :check_autorization_index
  
  def index
    render text: "signature verified"
    #DatabaseConnection::connect do |conn|
      #rs = conn.query("Select title from CART where number = 210660")
      #rs.first

      #création de cartouche - cut - fichier mp3
    #end
  end

  def upload
    render :json => params
    f = Rivendell::Import::File.new "BP"
    t = Rivendell::Import::Task.new :file => f
    c = Rivendell::Import::Cart.new t
    c.group = "MUSIC"
    c.create
  end

  private

  def check_autorization_index
    data = params[:data]

    api_key = Rails.configuration.x.api['api_key']

    hash = OpenSSL::HMAC.hexdigest('sha256', api_key, data)
    signature = request.headers['HTTP_SIGNATURE']

    if signature != hash
      head :forbidden
    end
  end
end
