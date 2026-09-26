# frozen_string_literal: true

require_relative "building"

# Represents a farm.
class Farm < Building
  class << self
    # @return [Integer]
    def build_cost = 20
    # @return [Integer]
    def sell_value_multiplier = 20
    # @return [Integer]
    def upgrade_cost_multiplier = 50
  end
end
