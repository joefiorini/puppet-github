require 'json'
require 'uri'

Puppet::Type.type(:github_api_request).provide(:https) do

  def exists?
    api_response(:get, resource[:url]) do |parsed_response|
      existing = parsed_response.select{|h| h.values.include? parsed_params["key"]}
      existing.any?
    end
  end

  def create
    api_response :post, resource[:url], parsed_params.to_json
  end

  private

  def execute_request type, url, body = nil
    uri = URI.parse("https://api.github.com#{url}")
    http = Net::HTTP.new uri.host, uri.port
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.start do |http|
      args = [:"request_#{type}", uri.path, body, auth_header].compact
      http.send(*args)
    end
  end

  def api_response type, url, body=nil, &block
    response = execute_request type, url, body
    response.value
    if block_given?
      block.call JSON.parse(response.body)
    end
  end

  def auth_header
    {"Authorization" => "token #{resource[:token]}"}
  end

  def parsed_params
    params = resource[:params]
    Hash[params.map do |k,v|
      value = processed_value v
      [k,value]
    end]
  end

  def processed_value value
    value_with_fn = value.split ':'
    if value_with_fn.length > 1
      case value_with_fn.first
      when 'read_file':
        File.read value_with_fn.last
      else
        value
      end
    else
      value
    end
  end
end
