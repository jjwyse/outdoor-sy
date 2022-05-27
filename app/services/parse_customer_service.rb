# frozen_string_literal: true

# Stateless service that takes in an array of Strings with some specified delimiter, parses the line into a Hash and
# then optionally filters and sorts the data before outputting an Array of Ruby Hashes, each representating an
# Outdoor.sy Customer.
class ParseCustomerService
  # Some dirty error definitions for our very rudimentary input validations
  class InvalidSortByError < StandardError; end
  class InvalidDelimiterError < StandardError; end
  class UnexpectedLineError < StandardError; end

  # [Sry, ew] The number of attributes we'd expect on each line after splitting by the specified delimiter
  EXPECTED_LINE_ATTRIBUTES = 6

  # Available options for sorting our customers
  SORT_BY_OPTIONS = %w[full_name vehicle_type].freeze

  # Available options for the delimiter
  DELIMITER_OPTIONS = %w[, |].freeze

  # @attribute lines: Array of Strings, with each entry being a String representation of an Outdoor.sy customer. This
  # function assumes *many* things about the input String, including TODO
  # @attribute delimiter: The character delimiter that is used between each attribute in the String representation of an
  # Outdoor.sy customer
  # @attribute sort_by: One of 'vehicle_type' or 'full_name'. Defaults to 'full_name'.
  def self.execute(file_name:, delimiter:, sort_by:)
    # Read file from file system
    file = File.open(file_name)
    lines = file.readlines.map(&:chomp)

    # Validate sort_by is supported
    raise InvalidSortByError unless SORT_BY_OPTIONS.include?(sort_by)

    # Validate delimiter is supported
    raise InvalidDelimiterError unless DELIMITER_OPTIONS.include?(delimiter)

    # Map over the given lines array, and parse into our Hash representation of an Outdoor.sy customer
    lines.map do |line|
      # Make sure our line ~roughly looks like we'd expect
      line_attributes = line.split(delimiter)
      raise UnexpectedLineError if line_attributes.count != EXPECTED_LINE_ATTRIBUTES

      # Outdoor.sy customer Hash representation
      {
        first_name: line_attributes[0],
        last_name: line_attributes[1],
        full_name: "#{line_attributes[0]} #{line_attributes[1]}",
        email: line_attributes[2],
        vehicle_type: line_attributes[3],
        vehicle_name: line_attributes[4],
        vehicle_length: line_attributes[5],
      }
    end
    .sort_by { |customer| customer[sort_by.to_sym].downcase }
  end
end