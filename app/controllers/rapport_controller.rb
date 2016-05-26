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
    #création de connection avec la db Rivendell
         con = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "radiocampus")
         con.select_db "Rivendell"
         
         #pour les requetes sql 
         formatted_date_begin = format_date begin_date
         formatted_date_end = format_date end_date
         formatted_date_current = formatted_date_begin
         
         # pour les conditions ruby
         to_date_begin = to_date begin_date
         to_date_end = to_date end_date
         to_date_current = to_date_begin
         
         # pour pqsser du format Date au string formatted
      
      # cas général
      #render :json => { :error => 'unsupported' }
       
       while to_date_current <= to_date_end do
       
       styles_rivendell.each_with_index do |style,j|
        reverse_date_current = reverse_date to_date_current
       query = "SELECT COUNT(l.ID) AS count FROM #{reverse_date_current}_LOG l, CART c
          WHERE GRACE_TIME = 0 AND CART_NUMBER = c.NUMBER AND c.SCHED_CODES LIKE '%#{style}%'"
          rs = con.query(query)
          counters[j] += rs.first['count']
          
          to_date_current=to_date_current +1.day 
          # a priori on peut faire comme ca mais a voir comment utiliser .tomorrow
          end
          end
        con.close

        render :json => result_hash(styles_disco, counters)

     
    else   
    # cas impossible mais bon, il fallait le faire 

      render :json => { :error => 'invalid date' }
    end

  end

  private

  def valid_date?(date_string)
    d, m, y = date_string.split '/'
    Date.valid_date? y.to_i, m.to_i, d.to_i
  end
  
  def to_date(date_string)
   d, m, y = date_string.split '/'
   Date.new(y.to_i, m.to_i, d.to_i)
  end
  
  def format_date(date_string)
    d, m, y = date_string.split '/'
    "#{y}_#{m}_#{d}"
  end
  
  def result_hash(keys, values)
    zipped = keys.zip(values)
    Hash[zipped]
  end
  
  def reverse_date(date)
  old =date.to_s
  y,m,d= old.split '-'
  
  "#{y}_#{m}_#{d}"
  
  end
end
