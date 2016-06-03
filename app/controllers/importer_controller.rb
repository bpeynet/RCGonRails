class ImporterController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :check_authorization
  
  def index
    render :json => params
    file = params['multifile_0']
    data = ActiveSupport::JSON.decode params['data']
    c = get_cart file, data
    c.import
  end

  private

  def sanitize_filename(filename)
    return File.basename(filename)
  end

  def check_authorization
    file = params['multifile_0']
    if !file.nil? && signature_verified?(file.read)
      return true
    end
    head :forbidden
    return false
  end

  def get_cart(file, data)
    c = Cart.new :file => file

    c.title = data['titre']
    c.artist = data['artiste']
    c.album = data['album']
    c.scheduler_codes = []
    styles_disco = data['styles']
    styles_disco << data['genre']
    styles_disco.each do |style_disco|
      style_rivendell = mapping_hash[style_disco]
      unless style_rivendell.nil?
	c.scheduler_codes << style_rivendell
      end
    end
    c.scheduler_codes << "MuPlayList"
    if data['fr'] 
      c.scheduler_codes << "MuFR"
    end
    c
  end

end
