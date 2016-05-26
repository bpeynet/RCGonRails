class RapportController < ApplicationController
  def index
    begin_date = params[:begin_date]
    end_date = params[:end_date]

    #styles_disco = params[:styles]
    styles_disco = [ 164, 4]  

    counters = []
    styles_disco.each { counters << 0 }

    # effectue le mapping entre les styles Disco et Rivendell
    styles_rivendell = styles_disco.map { |style| disco_to_rivendell style }


    if valid_date?(begin_date) && valid_date?(end_date)
      if begin_date != end_date
        render :json => { :error => 'unsupported' }
      else

        con = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "radiocampus")
        con.select_db "Rivendell"
        formatted_date = format_date begin_date
        styles_rivendell.each_with_index do |style, i|
          # sur la table, si GRACE_TIME = 0 alors c'est une musique et pas une émission
          query = "SELECT COUNT(l.ID) AS count FROM #{formatted_date}_LOG l, CART c
          WHERE GRACE_TIME = 0 AND CART_NUMBER = c.NUMBER AND c.SCHED_CODES LIKE '%#{style}%'"
          rs = con.query(query)
          counters[i] += rs.first['count']
        end
        con.close

        render :json => result_hash(styles_disco, counters)

      end
    else
      render :json => { :error => 'invalid date' }
    end
​
  end
​
  private
​
  def valid_date?(date_string)
    d, m, y = date_string.split '/'
    Date.valid_date? y.to_i, m.to_i, d.to_i
  end


  def format_date(date_string)
    d, m, y = date_string.split '/'
    "#{y}_#{m}_#{d}"
  end

  def result_hash(keys, values)
    zipped = keys.zip(values)
    Hash[zipped]
  end

end
