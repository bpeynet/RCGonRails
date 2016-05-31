class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def mapping_hash
    @mapping_hash ||= YAML.load_file(Rails.root.join('config', 'styles.yml'));
  end

end
