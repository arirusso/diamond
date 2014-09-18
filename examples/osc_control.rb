#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

# A simple OSC control setup
# You'll need the osc-ruby gem which doesn't bundle with diamond by default

require "diamond"

@output = UniMIDI::Output.gets

osc_map = [
  { :property => :interval, :address => "/1/rotaryA", :value => (0..1.0) },
  { :property => :transpose, :address => "/1/rotaryB" }
]

options = { 
  :gate => 90,   
  :interval => 7,
  :midi => @output,
  :osc_map => osc_map,
  :osc_port => 8000,
  :pattern => Diamond::Pattern["UpDown"],
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
