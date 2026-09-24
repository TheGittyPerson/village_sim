# frozen_string_literal: true

require "json"
require "io/console"

require_relative "village"
require_relative "action_marker"
require_relative "command_parser"
require_relative "debugger"
require_relative "ui_utils"

# Main game class
class VillageSim
  include UIUtils
  extend ActionMarker

  attr_accessor :village, :parser
  attr_reader :data

  def initialize
    @json_file_name = 'village_sim_data.json'
    @json_file_path = __dir__ + '/' + @json_file_name

    @data = load_data # @type [Hash{Symbol => Object}]
    @village = Village.new(self) # @type [Village]
    @parser = CommandParser.new(self)
    @debugger = Debugger.new(self)
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

  # Show help message.
  #
  # If the `commands` or `c` flag is passed, only shows the list of commands.
  # @param args [Hash]
  action def help(args)
    contents = File.read("#{__dir__}/help.txt")
    if args.include?(:commands) || args.include?(:c)
      contents = contents.partition("LIST OF COMMANDS")[1..].join
    end
    puts
    puts contents.gsub("{VERSION}", VERSION)
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
  # @return [Hash]
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

  # Show game header.
  def show_header
    $stdout.clear_screen
    puts "\n" + " VILLAGE SIM! ".win_center("*=")
    puts "\nEnter 'help' for a list of commands."
  end
end
