class ImporterController < ApplicationController
  protect_from_forgery with: :null_session
  require 'database_connection'
  include DatabaseConnection
  before_action :check_authorization, :except => :upload
  before_action :check_authorization_upload, :only => :upload
  
  def index
    b = Rivendell::Import::Base.new
    f = Rivendell::Import::File.new "/home/ben/Bureau/Vanina.mp3"
    byebug
    t = b.create_task f
    render text: "signature verified"
    #DatabaseConnection::connect do |conn|
      #rs = conn.query("Select title from CART where number = 210660")
      #rs.first

      #création de cartouche - cut - fichier mp3
    #end
  end

  def upload
    render :json => params
    conf = Rivendell::Import::Config.new
    conf.rivendell.host = "192.168.1.10"
    conf.rivendell.db_url = "mysql://rduser:letmein@192.168.1.10/Rivendell"
    file = params['multifile_0']
    f = Rivendell::Import::File.new file.path
    t = Rivendell::Import::Task.new :file => f
    c = Rivendell::Import::Cart.new t
    c.group = "MUSIC"
    data = ActiveSupport::JSON.decode params['data']
    byebug

    c.create
    c.cut.create
    c.import f

    c.title = data['titre']
    c.artist = data['artiste']
    c.album = data['album']
    data['styles'].each do |style_disco|
      style_rivendell = mapping_hash[style_disco]
      unless style_rivendell.nil?
	c.scheduler_codes << style_rivendell
      end
    end
    style_rivendell = mapping_hash[data['genre']]
    unless style_rivendell.nil?
      c.scheduler_codes << style_rivendell
    end
    c.scheduler_codes << "MuPlayList"
    if data['fr'] 
      c.scheduler_codes << "MuFR"
    end
    c.update

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
    if !file.nil? && signature_verified?(file.read)
      return true
    end
    head :forbidden
    return false
  end

end
