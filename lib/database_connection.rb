module DatabaseConnection
  def self.connect
    conn = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "radiocampus")
    conn.select_db "Rivendell"
    yield conn
    conn.close
  end
end
