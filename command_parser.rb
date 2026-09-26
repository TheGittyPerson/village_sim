# frozen_string_literal: true

require_relative "ui_utils"
require_relative "debugger"
require_relative "version"

# Parses and executes user-inputted commands.
class CommandParser
  include UIUtils

  attr_accessor :action, :args

  # @param sim [VillageSim]
  def initialize(sim)
    @sim = sim # @type [VillageSim]
    @action = nil # @type [String, nil]
    @args = {} # @type [Hash]
  end

  # Prompts the user for a command and execute it
  def prompt_command
    inp = input("\n>> ")
    return if inp.empty?

    @action = inp.split.first.to_sym
    @args = hashify_args(inp.split[1..] || [])

    execute
  end

  # Executes a command.
  #
  # Any extra arguments are ignored.
  # Throws +:quit+ when quit command received.
  def execute
    case action
    when :day             then @sim.village.show_day
    when :nextday         then @sim.village.next_day
    when :save            then @sim.save_data
    when :stats           then @sim.village.stats
    when :rename          then @sim.village.rename
    when :clearscreen     then @sim.clear_screen
    when :help            then @sim.help
    when :debug           then @sim.debugger.debug
    when :quit, :exit     then throw :quit
    else error "Action unrecognized :("
    end
  end

  # Separates the list of arguments into positional and keyword arguments.
  #
  # This CLI treats the following as equivalent:
  #
  #   foo -bar
  #   foo --bar
  #
  # Keywords are lowercased and returned in the Hash as Symbols.
  # This command:
  #
  #   >> foo bar 123 --shiz biz -poof --bam true "indeed"
  #   # => ["bar", "123", "--shiz", "biz", "-poof", --bam, "true", "\"indeed\""]
  #
  # produces a hash like so:
  #
  #   {
  #     *: ["bar", "123"] # Positional arguments, right after the action
  #     shiz: ["biz"], # Keyword argument
  #     poof: [], # Keyword without any arguments acts as a flag
  #     bam: ["true", "\"indeed\""] # Multiple values can be passed to 1 keyword
  #   }
  #
  # @param args_str [Array<String>]
  # @return [Hash{Symbol => Array<String>}]
  def hashify_args(args_str)
    unless args_str.is_a? Array
      raise TypeError, "Expected Array, got #{args_str.class}"
    end

    out = { :* => [] }

    chunks = args_str.slice_before { |arg| arg.start_with?("-") }
    chunks.each do |chunk|
      first_item = chunk.first

      if first_item.start_with?("-")
        key = first_item.gsub(/\A-+/, "").downcase.to_sym
        values = chunk[1..]
        out[key] = values
      else
        out[:*].concat(chunk)
      end
    end

    out
  end
end
