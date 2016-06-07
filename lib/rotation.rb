module Rotation
  def self.rotate date
    require 'database_connection'
    include DatabaseConnection

    DatabaseConnection::connect do |conn|
      formatted_date = date.to_formatted_s(:db) # format yyyy-mm-dd

      query = "UPDATE CART
             SET SCHED_CODES=REPLACE(SCHED_CODES,'MuPlayList ','')
             WHERE SCHED_CODES LIKE '%MuPlayList%'
             AND METADATA_DATETIME < '#{formatted_date}'"
      conn.query(query)
    end
  end
end
