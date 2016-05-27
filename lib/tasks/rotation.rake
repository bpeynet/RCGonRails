# lib/tasks/rotation.rake
desc 'rotation of playlist'
task :rotation => [:environment] do
  con = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "radiocampus")
  con.select_db "Rivendell"
  two_months_ago = 2.months.ago.to_formatted_s(:db)

  query = "UPDATE CART
             SET SCHED_CODES=REPLACE(SCHED_CODES,'MuPlayList ','')
             WHERE SCHED_CODES LIKE '%MuPlayList%'
             AND METADATA_DATETIME < '#{two_months_ago}'"
  con.query(query)
  con.close
end
