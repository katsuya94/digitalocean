#!/usr/bin/env ruby
require "yaml"

paths = Dir.glob("/home/app/taskd/orgs/*/users/*/config")

config_regex = /^user=(?<user>.*)/
path_regex = %r{/home/app/taskd/orgs/(?<organization>[^/]+)/users/[^/]+/config}

users = paths.map do |path|
  user_line = File.readlines(path)
    .find { |line| config_regex =~ line }

  {
    "name" => config_regex.match(user_line)[:user],
    "organization" => path_regex.match(path)[:organization],
  }
end

puts YAML.dump(users)

