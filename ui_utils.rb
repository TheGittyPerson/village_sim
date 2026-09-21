# frozen_string_literal: true

require "io/console"

class String
  # Capitalize the first character of +self+ without touching anything else.
  # @return [String]
  def title
    split(" ").map { |word| word[0].upcase + (word[1..] || "") }.join(" ")
  end

  # Horizontally center a string based on the window width.
  # @param pad_string [String]
  # @return [String]
  def win_center(pad_string = " ")
    center($stdout.winsize.last, pad_string)
  end

  # Left-justify a string based on the window width
  # @param pad_string [String]
  # @return [String]
  def win_ljust(pad_string = " ")
    ljust($stdout.winsize.last, pad_string)
  end

  # Right-justify a string based on the window width
  # @param pad_string [String]
  # @return [String]
  def win_rjust(pad_string = " ")
    rjust($stdout.winsize.last, pad_string)
  end

  # @return [String]
  def bold
    "\e[1m#{self}\e[0m"
  end

  # @return [String]
  def dim
    "\e[2m#{self}\e[0m"
  end

  # @return [String]
  def red
    "\e[31m#{self}\e[0m"
  end

  # @return [String]
  def green
    "\e[32m#{self}\e[0m"
  end
end

class Array
  # Join the list with commas, but with the word "or" before the last item.
  # @return [String]
  def join_with_or
    case length
    when 0 then ""
    when 1 then first
    when 2 then join(" or ")
    else
      "#{self[0..-2].join(', ')}, or #{last}"
    end
  end
end

module UIUtils
  # Get user input.
  # @param prompt [String]
  # @param allowed [Array<String>, String]
  #   All accepted options (case-insensitive).
  #   Defaults to an empty array, which means that all inputs are allowed. If a
  #   string is passed, it is split into individual characters (recommended for
  #   one-character inputs).
  # @return [String]
  def input(prompt, allowed: [])
    allowed = allowed.chars if allowed.is_a? String
    loop do
      print prompt
      resp = gets.chomp.strip

      return resp if allowed.empty? || allowed.include?(resp.downcase)

      puts "\nError: ".bold.red + "Only enter #{allowed.join_with_or}"
    end
  end

  # Return formatted error message
  # @param msg [String]
  # @param newline [Boolean]
  # @return [String]
  def err(msg, newline: true)
    "#{"\n" if newline}Error: ".bold.red + msg.to_s
  end

  # Output formatted error message
  # @param msg [String]
  # @param newline [Boolean]
  def error(msg, newline: true)
    puts err(msg, newline: newline)
  end
end
