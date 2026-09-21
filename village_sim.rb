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

  def initialize
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

  def show_header
    $stdout.clear_screen
    puts "\n" + " VILLAGE SIM! ".win_center("*=")
  end

  def show_help
    puts
    puts File.read("#{__dir__}/help.txt").gsub("{VERSION}", VERSION)
  end
end
