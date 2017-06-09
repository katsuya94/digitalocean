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
    URI("https://api.digitalocean.com")
  end

  def self.authorization
    "Bearer #{ENV["DIGITALOCEAN_OAUTH_TOKEN"]}"
  end
end

OptionParser.new do |opts|
  opts.banner = "Usage: hosts.rb [options]"

  opts.on("--list") do
    hosts = DigitalOcean.list["droplets"]
      .map { |droplet| droplet["name"] }

    puts JSON.dump({"digitalocean" => hosts})
  end

  opts.on("--host HOSTNAME") do |hostname|
    droplet = DigitalOcean.list["droplets"]
      .find { |droplet| droplet["name"] == hostname }

    puts JSON.dump(
      "digitalocean" => droplet,
      "ansible_host" => droplet["networks"]["v4"].first["ip_address"],
    )
  end

  opts.on("--ip HOSTNAME") do |hostname|
    droplet = DigitalOcean.list["droplets"]
      .find { |droplet| droplet["name"] == hostname }

    puts droplet["networks"]["v4"].first["ip_address"]
  end
end.parse!
