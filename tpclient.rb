# frozen_string_literal: true

require 'net/http'

class TPClient
  attr :token, :org

  def initialize(token, org)
    @token = token or raise('token is not provided')
    @org = org or raise('org is not provided')
  end

  def retrieve(id)
    response = self.class.http_get(site, api_path(id), query)
    puts "tp response  id:#{id}, org:#{org}, code:#{response.code}, size:#{response.size}"
    return nil unless response.instance_of? Net::HTTPOK

    payload = JSON.parse(response.body, { object_class: OpenStruct })

    OpenStruct.new(
      id: payload.Id,
      name: payload.Name,
      type: payload.EntityType&.Name,
      owner: "#{payload.Owner&.FirstName} #{payload.Owner&.LastName}",
      url: site + web_path(id),
      )
  end

  def site
    "https://#{org}.tpondemand.com"
  end

  def web_path(id)
    "/entity/#{id}"
  end

  def api_path(id)
    "/api/v1/generals/#{id}"
  end

  def query
    "?format=json&access_token=#{token}"
  end

  def self::http_get(site, path, query)
    Net::HTTP.get_response(URI(site + path + query))
  end

  def self.from_env
    self.new(ENV['TP_ACCESS_KEY'], ENV['TP_ORG'])
  end
end
