#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

# Similar to "simple.rb" except the MIDI messages produced by the arpeggiator are printed to the screen
#
# There's no MIDI output

require "diamond"

options = { 
  :gate => 90,   
  :interval => 7,
  :midi => $stdout,
  :pattern => "UpDown",
  :range => 4, 
  :rate => 8
}

@clock = Diamond::Clock.new(101)
@arpeggiator = Diamond::Arpeggiator.new(options)
@clock << @arpeggiator

chord = ["C1", "G1", "Bb2", "A3"]
@arpeggiator.add(*chord)
@clock.start(:focus => true)
