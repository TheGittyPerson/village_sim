# frozen_string_literal: true

# TODO: Add global array for storing actions. just use a $ var
# TODO: Add method call system here to search for correct method.

# +extend+ this in classes that contain command action methods.
module ActionMarker
  # Returns an array of registered action method names (Symbols).
  #
  # Action methods are methods that respond to user commands, depending on
  # the action word in the command. They have an +args+ parameter that
  # accepts a Hash.
  # @return [Array<Symbol>]
  def actions
    @actions ||= []
  end

  # Stores command action method names in the class array.
  #
  #   action def example_action(args)
  #     # do stuff
  #   end
  #
  # Removes underscores from method names. Underscores are annoying to type
  # in commands.
  # @param method_name [Symbol]
  def action(method_name)
    method_name = method_name.name.gsub("_", "").to_sym
    @actions << method_name
  end
end
