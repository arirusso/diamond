#!/usr/bin/env ruby
$:.unshift(File.join("..", "lib"))

# This example shows how to define an arpeggiator pattern
#

require "diamond"

#
# The pattern procedure should return an array of numeric scale degrees.  For example,
# given (3, 7) the "Up" pattern will return [0, 7, 14, 21]
#
def fibonacci(n)
  n = fibonacci( n - 1 ) + fibonacci( n - 2 ) if n > 1
  n
end

Diamond::Pattern.add("fibonacci") { |range, interval| 0.upto(range).map { |n| fibonacci(n) } }

# Then the usual arpeggiator setup...

@output = UniMIDI::Output.gets

options = {
  :gate => 90,
  :range => 4,
  :interval => 7,
  :midi => @output,
  :rate => 8
}

@arpeggiator = Diamond::Arpeggiator.new(options)
@clock = Diamond::Clock.new(110)
@clock << @arpeggiator

chord = ["C3", "G3", "Bb3", "A4"]

@arpeggiator.add(chord)

# Assign the custom pattern...
@arpeggiator.pattern = Diamond::Pattern.find("fibonacci")

@clock.start(:focus => true)
