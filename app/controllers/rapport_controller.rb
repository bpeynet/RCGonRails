class RapportController < ApplicationController
  protect_from_forgery with: :null_session
  require 'database_connection'
  include DatabaseConnection
  def index
    begin_date_str = params[:begin_date]
    end_date_str = params[:end_date]
    styles_disco = ActiveSupport::JSON.decode params[:styles]

    @styles = init_styles styles_disco
    @result = init_result

    if valid_date?(begin_date_str) && valid_date?(end_date_str)

      # connection à la db Rivendell
      DatabaseConnection::connect do |con|
	@con = con

	begin_date = to_date(begin_date_str)
	end_date = to_date(end_date_str)

	# itération sur les jours entre les deux dates
	iterate_days(begin_date, end_date) do |current_date|
	  # recherche du nom de la table associée à la date
	  table_name = get_table_name current_date
	  if table_name.nil?
	    render :json => { :error => 'archives unavailables for these dates' }
	    return
	  else
	    update_result_for table_name
	  end
	end
	render :json => @result
      end
    else   
      # l'une des dates passée en paramètre est incorrecte
      render :json => { :error => 'invalid date' }
    end

  end

  private

  def init_styles
    styles_disco = ActiveSupport::JSON.decode params[:styles]

    # effectue le mapping entre les styles Disco et Rivendell
    styles_rivendell = styles_disco.map { |style| disco_to_rivendell(style.to_i) }
    styles_rivendell << "MuPlayList"

    result = {}
    styles_disco << :playlist
    styles_disco << :total
  end

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

  def format_date(date)
    old = date.to_s
    y,m,d = old.split '-'
    "#{y}#{m}#{d}"
  end

  def init_styles(styles_disco)
    mapping = mapping_hash
    styles = mapping_hash.keep_if { |k, v| styles_disco.include? k.to_s }
    styles[:playlist] = "MuPlayList"
    styles
  end

  def init_result
    result = {}

    @styles.each do |disco, rivendell| 
      result[disco] = { :count => 0, :distinct => 0, :length => 0 }
    end
    result[:total] = { :count => 0, :distinct => 0, :length => 0 }
    result
  end
  
  def get_table_name(date)
    formatted_current_date = format_date(date)
    query = "SELECT table_name FROM information_schema.tables 
    WHERE table_schema = 'Rivendell' AND table_name LIKE '%#{formatted_current_date}%'"
    rs = @con.query(query)
    if rs.count > 0
      tableName = rs.first['table_name']
    else
      nil
    end
  end

  def update_result_for(table_name)
    # itération sur les styles
    @styles.each do |disco, rivendell|
      if disco.nil?
	counters[i] = nil 
      else
	query = "SELECT COUNT(l.ID) AS count, COUNT(DISTINCT CART_NUMBER) AS count_distinct, SUM(c.AVERAGE_LENGTH) AS length 
          FROM #{table_name} l, CART c 
	  WHERE GROUP_NAME = 'MUSIC' AND CART_NUMBER = c.NUMBER AND c.SCHED_CODES LIKE '%#{rivendell}%'"
	rs = @con.query(query)
	@result[disco][:count] += rs.first['count'] || 0
	@result[disco][:distinct] += rs.first['count_distinct'] || 0
	@result[disco][:length] += rs.first['length'] || 0
      end
    end
    # calcul du total sur le jour
    query = "SELECT COUNT(l.ID) AS count, COUNT(DISTINCT CART_NUMBER) AS count_distinct, SUM(c.AVERAGE_LENGTH) AS length 
      FROM #{table_name} l, CART c
      WHERE GROUP_NAME = 'MUSIC' AND CART_NUMBER = c.NUMBER"
    rs = @con.query(query)
    @result[:total][:count] += rs.first['count'] || 0
    @result[:total][:distinct] += rs.first['count_distinct'] || 0
    @result[:total][:length] += rs.first['length'] || 0
  end

end
