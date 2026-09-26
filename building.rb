# frozen_string_literal: true

require_relative "ui_utils"

# Represents a building the village.
class Building
  include UIUtils

  class << self
    # @return [Integer]
    def build_cost
      raise "#{__method__} not implemented for class #{self}."
    end

    # @return [Integer]
    def sell_value_multiplier
      raise "#{__method__} not implemented for class #{self}."
    end

    # @return [Integer]
    def upgrade_cost_multiplier
      raise "#{__method__} not implemented for class #{self}."
    end

    # Starts building interaction to instantiate a new building.
    # @param sim [VillageSim]
    # @return [Building]
    def build(sim)
      if sim.village.money < build_cost
        puts "\nYour village doesn't have enough money to build a #{self} :("
        return
      end

      puts "\nBuilding a #{self}..."
      sleep 3
      puts "\nDone!"
      new(sim, level: 1)
    end
  end

  attr_accessor :level

  # kwargs:
  #   - +level+
  # @param sim [VillageSim]
  def initialize(sim, **kwargs)
    @sim = sim # @type [VillageSim]

    @data = Struct.new("Data", **kwargs)
    @level = kwargs[:level] # @type [Integer]
  end

  # Increase this building's level by the specified number.
  # Defaults to 1.
  # @param levels [Integer]
  def upgrade(levels = 1)
    @level += levels
  end

  # Gets sell cost of this building based on its level
  # @return [Integer]
  def sell_value
    (self.class.sell_value_multiplier * level).round
  end

  # Gets upgrade cost of this building based on its level
  # @return [Integer]
  def upgrade_cost
    (self.class.upgrade_cost_multiplier * level).round
  end

  # Serialize this building into a Hash.
  # Only includes the values passed to +new+ when initialized.
  # @return [Hash]
  def serialize
    {
      level: level
    }
  end
end
