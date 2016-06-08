module DatabaseConnection
  def self.connect
    conn = Mysql2::Client.new(:host => Rails.configuration.x.api['rivendell_host'], :username => Rails.configuration.x.api['rivendell_user'], :password => Rails.configuration.x.api['rivendell_password'])
    conn.select_db "Rivendell"
    yield conn
    conn.close
  end
end
