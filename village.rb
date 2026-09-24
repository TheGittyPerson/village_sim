# frozen_string_literal: true

require "io/console"

require_relative "ui_utils"

# Represent a village
class Village
  include UIUtils

  # @param sim [VillageSim]
  def initialize(sim)
    @sim = sim

    data = @sim.load_data.fetch(:village_info) do
      raise "Data missing :village_info"
    end

    @village_info_keys = []
    @name       = add_data(data, :name, "Unnamed")           # @type [String]
    @population = add_data(data, :population, 1)             # @type [Integer]
    @happiness  = add_data(data, :happiness, 100)            # @type [Integer]
    @knowledge  = add_data(data, :knowledge, 0)              # @type [Integer]
    add_data_getters

    save_data if data.empty?
  end

  # Loops through the Symbols in +@village_data_keys+ and creates new getters
  # methods for each respective instance variable they refer to.
  def add_data_getters
    @village_info_keys.each do |key|
      self.class.send(:define_method, key) { instance_variable_get("@#{key}") }
    end
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

  # Output village stats
  def show_stats
    puts "\n" + "~~~ #{name.upcase} VILLAGE STATS ~~~".win_center
    puts

    puts "Population: #{@population}"
    puts "Happiness: #{@happiness}%"
    puts "Knowledge: #{@knowledge}"
  end

  # @param new [String] or nil, which will show a prompt instead.
  def rename(new = nil)
    self.name = if new.nil?
                  input("\nGive your village a new name: ").title
                else
                  new.title
                end
    puts "\nName successfully set to #{name}!"
    save_data
  end

  # Performs a normal +fetch+ operation, but also adds the symbol keys to
  # +@village_data_keys+.
  # @param data [Hash{Symbol => T}]
  # @param key [Symbol]
  # @param default [D]
  # @return [T, D]
  def add_data(data, key, default)
    raise TypeError, "Expected Hash, got #{data.class}" unless data.is_a? Hash
    raise TypeError, "Expected Symbol, got #{key.class}" unless key.is_a? Symbol

    @village_info_keys << key
    data.fetch(key, default)
  end

  # Serializes village info as a Hash
  # @return [Hash{Symbol => Object}]
  def village_info_as_hash
    @village_info_keys.to_h { |sym|
      [sym, instance_variable_get("@#{sym}")]
    }
  end

  # Update +VillageSim.data+ and call the main +save_data+ method.
  def save_data
    @sim.data[:village_info]
  end
end
