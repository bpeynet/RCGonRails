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
    @api_key ||= Rails.configuration.x.api['api_key']
  end

  def signature_for(*content)
    sign = 0
    content.each do |c|
      sign ^= OpenSSL::HMAC.hexdigest('sha256', api_key, c).hex
    end
    sign.to_s(16).rjust(64, '0')
  end

  def client_signature
    request.headers['HTTP_SIGNATURE']
  end

  def signature_verified?(*content)
    client_signature == signature_for(*content)
  end

end
