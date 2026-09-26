# frozen_string_literal: true

require "io/console"

require_relative "farm"
require_relative "ui_utils"

# Represents a village.
class Village
  include UIUtils

  # The keys also act like a list of available buildings
  BUILDINGS_OBJ_MAPPING = {
    farms: Farm
  }.freeze

  attr_reader :name, :money, :population, :happiness, :food, :knowledge,
              :buildings

  # @param sim [VillageSim]
  def initialize(sim)
    @sim = sim

    data = @sim.load_data.fetch(:village) do
      raise "Data missing :village"
    end

    # Simple data items
    @name       = add_data(data, :name, "Unnamed")           # @type [String]
    @money      = add_data(data, :money, 100)                # @type [Integer]
    @population = add_data(data, :population, 1)             # @type [Integer]
    @happiness  = add_data(data, :happiness, 100)            # @type [Integer]
    @food       = add_data(data, :food, 0)                   # @type [Integer]
    @knowledge  = add_data(data, :knowledge, 0)              # @type [Integer]

    # Complex data items
    @buildings  = parse_buildings(data)

    update_data if data.empty?
  end

  # @!group Command Action Methods

  # Shows the current day number.
  def show_day
    puts "\nIt's currently day #{day}."
  end

  # Moves on to the next day in the simulation. This is a command action method.
  #
  # Accepts an integer command argument that defines how many days to move
  # ahead by.
  def next_day
    incr = @sim.parser.args[:*].first || 1
    puts "\nMoving forward by #{incr} day(s)...\n"
    self.day += incr
    update_data
  end

  # Outputs village stats. This is a command action method.
  def stats
    puts "\n" + "~~~ #{name.upcase} VILLAGE STATS ~~~".win_center
    puts

    puts "Population: #{@population}"
    puts "Happiness: #{@happiness}%"
    puts "Knowledge: #{@knowledge}"
  end

  # Renames the village. This is a command action method.
  #
  # Directly uses the passed argument from the command if given, otherwise
  # uses a prompt.
  def rename
    self.name = if @sim.parser.args[:*].first.nil?
                  input("\nGive your village a new name: ").title
                else
                  @sim.parser.args[:*].first.title
                end
    puts "\nName successfully set to #{name}!"
    update_data
  end

  # @!endgroup

  # @!group Complex Data Item Parsers/Serializers

  # Parses buildings Hashes into +Building+ objects and stores it in @buildings.
  # @param data [Hash]
  # @return [Hash]
  def parse_buildings(data)
    return {} if data.empty? || !data.include?(:buildings)

    buildings_data = data[:buildings]

    out = {}
    BUILDINGS_OBJ_MAPPING.each_pair do |building_type, building_cls|
      out[building_type] = buildings_data[building_type].map { |building_data|
        building_cls.new(@sim, **building_data)
      }
    end
    out
  end

  # Serializes buildings into Hashes.
  # Should only be called by +serialize_data+.
  # @return [Hash]
  def serialize_buildings
    out = {}
    @buildings.each_pair do |building_type, building_objs|
      out[building_type] = building_objs.map(&:serialize)
    end
    out
  end

  # @!endgroup

  # Current day of simulation. First visit starts on Day 0.
  # @return [Integer]
  def day
    @sim.data.fetch(:day) do
      raise "Data missing key :day"
    end
  end

  # Increase +money+ by the specified amount.
  # @param amount [Integer]
  def earn_money(amount)
    unless amount.is_a? Integer
      raise TypeError, "Expected Integer, got #{amount.class}"
    end 
    @money += amount
  end

  # Decrease +money+ by the specified amount.
  # @param amount [Integer]
  def lose_money(amount)
    unless amount.is_a? Integer
      raise TypeError, "Expected Integer, got #{amount.class}"
    end
    @money -= [amount, @money].min
  end
  
  # Whether +money+ is +0+.
  # @return [Boolean]
  def broke?
    money.zero?
  end

  # Sets day number in data Hash. Does *NOT* save to file.
  # @param number [Integer]
  def day=(number)
    @sim.data[:day] = number
  end

  # @param str [String]
  def name=(str)
    raise TypeError, "Expected String, got #{str.class}" unless str.is_a? String
    @name = str
  end

  # @param int [Integer]
  def population=(int)
    unless int.is_a? Integer
      raise TypeError, "Expected Integer, got #{int.class}"
    end
    @population = int.negative? ? 0 : int
  end

  # @param int [Integer]
  def happiness=(int)
    unless int.is_a? Integer
      raise TypeError, "Expected Integer, got #{int.class}"
    end
    @happiness = int.clamp(0, 100)
  end

  # @param int [Integer]
  def knowledge=(int)
    unless int.is_a? Integer
      raise TypeError, "Expected Integer, got #{int.class}"
    end
    @happiness = int.clamp(0, 100)
  end

  # Add a getter for the specified name.
  # @param name [Symbol]
  def add_getter(name)
    unless name.is_a? Symbol
      raise TypeError, "Expected Symbol, got #{name.class}"
    end
    self.class.send(:define_method, key) { instance_variable_get("@#{name}") }
  end

  # Performs a normal +fetch+ operation, but also adds the symbol keys to
  # +@simple_data_keys+.
  # For simple data items that don't require serialization/deserialization.
  # @param data [Hash{Symbol => T}]
  # @param key [Symbol]
  # @param default [D]
  # @return [T, D]
  def add_data(data, key, default)
    raise TypeError, "Expected Hash, got #{data.class}" unless data.is_a? Hash
    raise TypeError, "Expected Symbol, got #{key.class}" unless key.is_a? Symbol

    @simple_data_keys ||= []
    @simple_data_keys << key
    data.fetch(key, default)
  end

  # Serializes village data as a Hash
  # @return [Hash{Symbol => Object}]
  def serialize_data
    out = @simple_data_keys.to_h { |sym|
      [sym, instance_variable_get("@#{sym}")]
    }
    out[:buildings] = serialize_buildings
    out
  end

  # Updates +VillageSim.data+.
  def update_data
    @sim.data[:village] = serialize_data
  end
end
