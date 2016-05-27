class RapportController < ApplicationController
  protect_from_forgery with: :null_session
  def index
    begin_date_str = params[:begin_date]
    end_date_str = params[:end_date]

    styles_disco = ActiveSupport::JSON.decode params[:styles]

    # liste des compteurs par style et le total
    counters = Array.new(styles_disco.count + 1, 0)

    # effectue le mapping entre les styles Disco et Rivendell
    styles_rivendell = styles_disco.map { |style| disco_to_rivendell(style.to_i)}

    if valid_date?(begin_date_str) && valid_date?(end_date_str)
      #création de connection avec la db Rivendell
      con = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "radiocampus")
      con.select_db "Rivendell"

      begin_date = to_date(begin_date_str)
      end_date = to_date(end_date_str)

      # itération sur les jours entre les deux dates
      iterate_days(begin_date, end_date) do |current_date|
        formatted_current_date = format_date(current_date)

        # boucle sur les styles
        # la combinaison aléatoire des styles dans la colonne SCHED_CODES ne permet pas
        # de faire cela en une seule requête
        styles_rivendell.each_with_index do |style, i|
          if style.nil?
            counters[i] = 'na'
          else
            query = "SELECT COUNT(l.ID) AS count FROM #{formatted_current_date}_LOG l, CART c
          WHERE GRACE_TIME = 0 AND CART_NUMBER = c.NUMBER AND c.SCHED_CODES LIKE '%#{style}%'"
            rs = con.query(query)
            counters[i] += rs.first['count']
          end
        end

        # calcul du total sur le jour
        query = "SELECT COUNT(l.ID) AS count FROM #{formatted_current_date}_LOG l, CART c
          WHERE GRACE_TIME = 0 AND CART_NUMBER = c.NUMBER"
        rs = con.query(query)
        counters[counters.count - 1] += rs.first['count']
      end

      con.close

      # ajout de la colonne total pour rendu json
      styles_disco << :total
      render :json => result_hash(styles_disco, counters)
    else   
      # l'une des dates passée en paramètre est incorrecte
      render :json => { :error => 'invalid date' }
    end

  end

  private

  def valid_date?(date_string)
    d, m, y = date_string.split '/'
    Date.valid_date? y.to_i, m.to_i, d.to_i
  end

  def iterate_days(begin_date, end_date)
    current_date = begin_date
    while current_date <= end_date do
      yield current_date
      current_date = current_date + 1.day
    end
  end

  def to_date(date_string)
    d, m, y = date_string.split '/'
    Date.new(y.to_i, m.to_i, d.to_i)
  end

  def result_hash(keys, values)
    zipped = keys.zip(values)
    Hash[zipped]
  end

  def format_date(date)
    old = date.to_s
    y,m,d = old.split '-'
    "#{y}_#{m}_#{d}"
  end

end
