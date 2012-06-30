require 'json'
require 'uri'

Puppet::Type.type(:github_api_request).provide(:https) do

  def exists?
    api_response(:get, resource[:url]) do |parsed_response|
      parsed_response.any? do |h|
        h.values.include? parsed_params["key"]
      end
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
    Puppet.debug("Making #{type} request to #{uri.inspect} with headers:\n\n #{auth_header.inspect} \n\nand body:\n\n#{body}")
    http.start do |http|
      args = [:"request_#{type}", uri.path, body, auth_header].compact
      http.send(*args)
    end
  end

  def api_response type, url, body=nil, &block
    response = execute_request type, url, body
    response.value
    Puppet.debug("Received response #{response.class.name} with body:\n\n#{response.body.inspect}")
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
        File.read(value_with_fn.last).strip
      else
        value
      end
    else
      value
    end
  end

end
