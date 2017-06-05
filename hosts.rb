#!/usr/bin/env ruby
require "dotenv/load"
require "net/http"
require "uri"
require "json"
require "optparse"

class DigitalOcean
  def self.list
    request = Net::HTTP::Get.new("/v2/droplets")
    request.add_field("Content-Type", "application/json")
    request.add_field("Authorization", authorization)

    response = with_http do |http|
      http.request request
    end

    JSON.parse(response.body)
  end

  private

  def self.with_http(&block)
    Net::HTTP.start(uri.host, uri.port, :use_ssl => use_ssl, &block)
  end

  def self.use_ssl
    uri.scheme = "https"
  end

  def self.uri
    uri = URI("https://api.digitalocean.com")
  end

  def self.authorization
    "Bearer #{ENV["DIGITALOCEAN_OAUTH_TOKEN"]}"
  end
end

OptionParser.new do |opts|
  opts.banner = "Usage: hosts.rb [options]"

  opts.on("--list") do
    hosts = DigitalOcean.list["droplets"].flat_map do |droplet|
      droplet["networks"]["v4"].map { |network| network["ip_address"] }
    end

    puts JSON.dump({"digitalocean" => hosts})
  end

  opts.on("--host HOSTNAME") do |_hostname|
    puts JSON.dump({})
  end
end.parse!
