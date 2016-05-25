class RapportController < ApplicationController
  def index
    begin_date = params[:begin_date]
    end_date = params[:end_date]
    styles = params[:styles]

    # effectue le mapping entre les styles Disco et Rivendell
    styles.map! { |style| disco_to_rivendell style }

    if valid_date?(begin_date) && valid_date?(end_date)
      render :json => []
    else
      render :json => { :error => 'invalid date' }
    end

  end

  private

  def valid_date?(date_string)
    d, m, y = date_string.split '/'
    Date.valid_date? y.to_i, m.to_i, d.to_i
  end

end
