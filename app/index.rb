#!/usr/bin/env ruby

require 'json'
require_relative './services/parse_customer_service'

# Parses CLI arguments, and exit(1) if CLI arguments are invalid
def parse_arguments!
  # Naively parse CLI arguments
  file_name = ARGV[0]
  delimiter = ARGV[1]
  sort_by = ARGV[2]

  if file_name.nil? || delimiter.nil? || sort_by.nil?
    pp 'Invalid input arguments'
    pp ''
    pp 'Examples:'
    pp "  $ app/index.rb pipes.txt '|' full_name"
    pp "  $ app/index.rb commas.txt ',' vehicle_type"
    pp ''
    exit(1)
  end

  [file_name, delimiter, sort_by]
end


# Read CLI args and delegate to our service
file_name, delimiter, sort_by = parse_arguments!
customers = ParseCustomerService.execute(
  file_name: "data/#{file_name}",
  delimiter: delimiter,
  sort_by: sort_by,
)

# Write output to file, and then cat it for our CLI
File.open('output.json', 'w') { |file| file.write(JSON.pretty_generate(customers)) }
system('cat output.json')