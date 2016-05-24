class ImporterController < ApplicationController
  protect_from_forgery with: :null_session
  def index
    tab = { :hello => "world" }
    render :json => tab
  end
end
