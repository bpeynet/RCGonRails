class Cart
  attr_accessor :title, :artist, :album, :scheduler_codes

  def initialize(options = {})
    conf = Rivendell::Import::Config.new
    
    conf.rivendell.host = Rails.configuration.x.api['rivendell_host']
    conf.rivendell.db_url = Rails.configuration.x.api['rivendell_db_url']

    @f = Rivendell::Import::File.new options[:file].path
    t = Rivendell::Import::Task.new :file => @f
    @c = Rivendell::Import::Cart.new t
    @c.group = "MUSIC"
  end

  def import
    @c.create
    @c.cut.create
    @c.import @f
    @c.title = title
    @c.artist = artist
    @c.album = album
    @c.scheduler_codes = scheduler_codes
    @c.update
  end
end
