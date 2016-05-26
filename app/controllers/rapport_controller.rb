class RapportController < ApplicationController
  def index
    begin_date = params[:begin_date]
    end_date = params[:end_date]
    styles_disco = params[:styles]
    styles_rivendell = styles_disco
​
    counters = []
    styles_disco.each { counters << 0 }
​
    # effectue le mapping entre les styles Disco et Rivendell
    styles_rivendell.map! { |style| disco_to_rivendell style }
​
    if valid_date?(begin_date) && valid_date?(end_date)
      if begin_date != end_date
        render :json => { :error => 'unsupported' }
      else
        styles_rivendell.each do |style|
          query = "SELECT COUNT(l.ID) FROM #{formatted_date}_LOG l, CART c
          WHERE GRACE_TIME = 0 AND CART_NUBER = c.NUMBER AND SCHED_CODES LIKE '%#{style}%'"
        end
​
        render :json => []
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
​
end
