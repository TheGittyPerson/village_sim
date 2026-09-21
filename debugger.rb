# frozen_string_literal: true

require_relative "ui_utils"

module Debugger
  extend UIUtils

  module_function

  # Parse debug command
  # @param args [Array<String>]
  # @param base_object [VillageSim]
  def debug_command(args, base_object)
    if args.empty?
      start_interactive_debug base_object
    else
      puts "\n=> #{lookup_value(args, base_object)}"
    end
  end

  # Start an interactive debug session
  # @param base_object [Object]
  def start_interactive_debug(base_object)
    puts
    puts "?-- Interactive Debug --?".win_center
    puts "\nType 'help' for help."
    loop do
      inp = input("\n>? ")
      case inp
      when "help" then show_help
      when "quit", "exit" then break
      else
        puts "\n=> #{lookup_value(inp.split, base_object)}"
      end
    end
    puts "\nExited Interactive Debug"
  end

  # Look up the return value of a method and return the value.
  # @param cmd_args [Array<String>]
  # @param [Object]
  # @return [String]
  def lookup_value(cmd_args, base_object)
    unless cmd_args.is_a? Array
      raise TypeError, "Expected Array, got #{cmd_args.class}"
    end
    
    full_method, *args = cmd_args
    methods = full_method.split('.')

    current_value = base_object

    methods.each_with_index do |method_name, index|
      is_last_method = (index == methods.size - 1)
      current_value = if is_last_method
                        current_value.send(
                          method_name, *args.map { |arg| convert_type arg }
                        )
                      else
                        current_value.send(method_name)
                      end
    rescue StandardError => e
      return err(e.message, newline: false)
    end

    current_value.inspect
  end

  # Guessed what type the user-inputted string is supposed to be
  # and converts it.
  # @param arg [String]
  # @return [String, Integer, Float, Symbol, Boolean]
  def convert_type(arg)
    case arg
    when "true" then true
    when "false" then false
    when /\A\d+\.\d+\z/ then arg.to_f
    when /\A\d+\z/ then arg.to_i
    when /\A:[a-zA-Z_]\w*\z/ then arg.to_sym
    else arg
    end
  end

  def show_help
    puts "\nINTERACTIVE DEBUG MODE — Help".bold
    puts "\nType in the names of any method to call them."
    puts "Type any arguments following the name of the method."
    puts "This runs from the scope of the main VillageSim instance."
    puts "You can use dot notation for accessing deeper methods."
    puts "Type 'quit' or 'exit' to exit interactive debug."
  end
end
