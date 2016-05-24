class ImporterController < ApplicationController
  def index
    tab = { :hello => "world" }
    render :json => tab
  end
end
