# frozen_string_literal: true

require_relative "ui_utils"
require_relative "debugger"
require_relative "version"

class CommandParser
  include UIUtils

  # @param sim [VillageSim]
  def initialize(sim)
    @sim = sim # @type [VillageSim]
  end

  # Prompts the user for a command and execute it
  def prompt_command
    inp = input("\n>> ").split
    return if inp.empty?

    execute(inp.first.to_sym, inp[1..] || [])
  end

  # Executes a command.
  #
  # Any extra arguments are ignored.
  # Throws +:quit+ when quit command received.
  # @param command [Symbol]
  # @param args [Array<Object>]
  def execute(command, args)
    args = self.class.separate_args *args
    case command
    when :stats
      @sim.village.show_stats
    when :rename
      @sim.village.change_name(args.first)
    when :clearscreen
      @sim.show_header
    when :help
      @sim.show_help
    when :debug
      Debugger.debug_command(args[:*], @sim)
    when :quit, :exit
      throw :quit
    else error "Command unrecognized :("
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
  # @param args [Array<String>]
  # @return [Hash{Symbol => Array<String>}]
  def self.separate_args(*args)
    raise TypeError, "Expected Array, got #{args.class}" unless args.is_a? Array

    out = { :* => [] }

    chunks = args.slice_before { |arg| arg.start_with?("-") }
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
