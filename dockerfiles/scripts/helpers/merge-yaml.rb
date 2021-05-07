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

# Taken from: https://stackoverflow.com/a/55705853
def duplicate_keys(content)
  duplicate_keys = []

  validator = ->(node, parent_path) do
    if node.is_a?(Psych::Nodes::Mapping)
      children = node.children.each_slice(2) # In a Mapping, every other child is the key node, the other is the value node.
      duplicates = children.map(&:first).group_by(&:value).select { |_value, nodes| nodes.size > 1 }

      duplicates.each do |key, nodes|
        duplicate_keys.append(
          key: parent_path + [key],
          occurrences: nodes.map { |occurrence| "line: #{occurrence.start_line + 1}" }
        )
      end

      children.each do |key_node, value_node|
        key_node_value = key_node.respond_to?(:value) ? key_node.value : nil
        validator.call(value_node, parent_path + [key_node_value].compact)
      end
    else
      node.children.to_a.each { |child| validator.call(child, parent_path) }
    end
  end

  ast = Psych.parse_stream(content)
  validator.call(ast, [])

  duplicate_keys if duplicate_keys.any?
end

config = ARGV.inject({}) do |config, arg|
  file_name, *digs = arg.split(':')

  # we dig into our config
  content = File.read(file_name)
  content = ERB.new(content).result

  unless file_name.end_with?('.example')
    if duplicates = duplicate_keys(content)
      STDERR.puts "Found #{duplicates.count} duplicates in #{file_name}:"
      duplicates.each do |duplicate|
        STDERR.puts "- '#{duplicate[:key].join('.')} at #{duplicate[:occurrences].join(', ')}"
      end
      exit 1
    end
  end

  content = YAML.load(content) || {}
  content = content.dig(*digs) if digs.any?

  deep_merge(config, content || {})
end

puts config.to_yaml
