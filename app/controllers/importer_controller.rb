class ImporterController < ApplicationController
  protect_from_forgery with: :null_session
  require 'database_connection'
  include DatabaseConnection
  before_action :check_authorization, :except => :upload
  before_action :check_authorization_upload, :only => :upload
  
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

  def sanitize_filename(filename)
    return File.basename(filename)
  end

  def check_authorization
    data = params[:data]

    if !signature_verified? data
      head :forbidden
      return false
    end
  end

  def check_authorization_upload
    file = params['multifile_0']
    if file && signature_verified?(file.read)
      return
    end
    head :forbidden
    return false
  end

end
