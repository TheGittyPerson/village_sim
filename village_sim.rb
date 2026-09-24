# frozen_string_literal: true

require "json"
require "io/console"

require_relative "village"
require_relative "command_parser"
require_relative "ui_utils"

# Main game class
class VillageSim
  include UIUtils

  attr_accessor :village, :parser
  attr_reader :data

  def initialize
    @data = load_data # @type [Hash{Symbol => Object}]
    @village = Village.new(self)
    @parser = CommandParser.new(self)
  end

  # Main loop
  def run
    show_header
    catch :quit do
      loop do
        @parser.prompt_command
      end
    end
  end

  # @param hash [Hash{Symbol => Object}]
  def data=(hash)
    expected_keys = %i[village day]
    
    raise TypeError, "Expected Hash, got #{hash.class}" unless hash.is_a? Hash
    unless hash.keys.all? { |key| key.respond_to? to_sym }
      raise ArgumentError,
            "Argument should be symbolizable (got type #{hash.class})."
    end

    expected_keys.each do |key|
      raise ArgumentError, "Missing key :#{key}" unless data.key? key
    end
    @data = hash
  end

  # Load JSON data from a file and parse as a Hash.
  # Keys are symbolized.
  # @return [Hash{Symbol => Object}]
  def load_data
    return {} unless File.exist? @json_file_path
    contents = File.read(@json_file_path)
    JSON.parse(contents, symbolize_names: true)
  end

  # Save village data to the JSON file.
  def save_data
    File.write(
      @json_file_path,
      JSON.pretty_generate(data)
    )
    nil
  end

  def show_header
    $stdout.clear_screen
    puts "\n" + " VILLAGE SIM! ".win_center("*=")
  end

  def show_help
    puts
    puts File.read("#{__dir__}/help.txt").gsub("{VERSION}", VERSION)
  end
end
