#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require "diamond"

@output = UniMIDI::Output.gets

opts = { 
  :gate => 90, 
  :range => 4, 
  :interval => 7,
  :midi => @output,
  :rate => 8
}

arp = Diamond::Arpeggiator.new(112, opts)

chord = ["C3", "G3", "Bb3", "A4"]

arp.add(chord)

#
# the Pattern Proc should return a set of scale degrees.
#  for example, given (3, 7) the "Up" pattern will return [0, 7, 14, 21]
#
arp.pattern = Diamond::Pattern.new("Up") do |r, i|
  a = []
  0.upto(r) { |n| a << (n * i) }
  a
end
   
arp.start(:focus => true)
