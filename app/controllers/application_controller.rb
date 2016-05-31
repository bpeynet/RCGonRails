class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  require 'openssl'

  protected

  def mapping_hash
    @mapping_hash ||= YAML.load_file(Rails.root.join('config', 'styles.yml'));
  end

  def api_key
    Rails.configuration.x.api['api_key']
  end

  def signature_for(content)
    OpenSSL::HMAC.hexdigest('sha256', api_key, content)
  end

  def client_signature
    request.headers['HTTP_SIGNATURE']
  end

  def signature_verified?(content)
    client_signature == signature_for(content)
  end

end
