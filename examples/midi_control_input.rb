#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

# Control the arpeggiator using MIDI control change messages

require "diamond"

@input = UniMIDI::Input.gets
@output = UniMIDI::Output.gets

midi_map = [
  { 
    :property => :interval, 
    :index => 1
  },
  { 
    :property => :transpose, 
    :index => 2
  }
  # etc
]

options = { 
  :gate => 90,   
  :interval => 7,
  :midi => [@input, @output],
  :pattern => "UpDown",
  :range => 4, 
  :rate => 8,
  :midi_control => midi_map,
  :midi_debug => true
}

@clock = Diamond::Clock.new(101)
@arpeggiator = Diamond::Arpeggiator.new(options)
@clock << @arpeggiator

chord = ["C1", "G1", "Bb2", "A3"]
@arpeggiator.add(*chord)
@clock.start(:focus => true)
