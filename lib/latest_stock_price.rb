require "dotenv/load"
require "net/http"
require "uri"
require "singleton"

class LatestStockPrice
  include Singleton

  def initialize
    @base_uri = ENV["API_URL"]
    @api_key = ENV["API_KEY"]
    @api_host = ENV["API_HOST"]
  end

  def price_all
    uri = URI("#{@base_uri}/any")
    request = Net::HTTP::Get.new(uri)
    request["x-rapidapi-host"] = @api_host
    request["x-rapidapi-key"] = @api_key

    begin
      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
      raise BadGatewayError.new("Failed to get latest stock price") unless res.is_a?(Net::HTTPSuccess)

      JSON.parse(res.body)
    rescue SocketError => e
      raise BadGatewayError.new(e.message)
    end
  end
end
