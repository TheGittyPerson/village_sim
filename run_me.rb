# frozen_string_literal: true

require_relative "village_sim"
require_relative "village"

if __FILE__ == $PROGRAM_NAME
  village = VillageSim.new
  village.run
end
