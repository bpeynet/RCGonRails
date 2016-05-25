class RapportController < ApplicationController
  def index
    data = []
    render :json => data
  end
end
