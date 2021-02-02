#!/usr/bin/env ruby

require 'yaml'
require 'erb'

def deep_merge!(hash, other_hash, &block)
  other_hash.each_pair do |current_key, other_value|
    this_value = hash[current_key]

    hash[current_key] = if this_value.is_a?(Hash) && other_value.is_a?(Hash)
      deep_merge(this_value, other_value, &block)
    else
      if block_given? && key?(current_key)
        block.call(current_key, this_value, other_value)
      else
        other_value
      end
    end
  end

  hash
end

def deep_merge(hash, other_hash, &block)
  deep_merge!(hash.dup, other_hash, &block)
end

config = ARGV.inject({}) do |config, arg|
  file_name, *digs = arg.split(':')

  # we dig into our config
  content = File.read(file_name)
  content = ERB.new(content).result
  content = YAML.load(content) || {}
  content = content.dig(*digs) if digs.any?

  deep_merge(config, content || {})
end

puts config.to_yaml
