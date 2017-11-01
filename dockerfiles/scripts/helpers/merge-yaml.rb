#!/usr/bin/ruby

require 'yaml'
require 'rails'

config = ARGV.inject({}) do |config, arg|
  config.deep_merge(YAML.load_file(arg))
end

puts config.to_yaml
