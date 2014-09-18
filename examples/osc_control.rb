#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

# Use OSC to control the arpeggiator

require "diamond"

@output = UniMIDI::Output.gets

osc_map = [
  { 
    :property => :interval, 
    :address => "/1/rotaryA", 
    :value => (0..1.0) # value is optional, defaults to 0..1.0
  },
  { 
    :property => :transpose, 
    :address => "/1/rotaryB" 
  }
  # etc
]

options = { 
  :gate => 90,   
  :interval => 7,
  :midi => @output,
  :osc_control => osc_map,
  :osc_port => 8000,
  :osc_debug => true,
  :pattern => "UpDown",
  :range => 4, 
  :rate => 8,
  :resolution => 128
}

@arpeggiator = Diamond::Arpeggiator.new(options)
@clock = Diamond::Clock.new(110)
@clock << @arpeggiator

chord = ["C1", "G1", "Bb2", "A3"]
@arpeggiator.add(*chord)
@clock.start(:focus => true)
