#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

#
# this is the most basic setup possible
# we just set up an arpeggiator and let it run in the foreground
#

require "diamond"

@output = UniMIDI::Output.gets

map = [
  { 
    :class => MIDIMessage::ControlChange,
    :index => 0,
    :input_range => (0..127),
    :range => (-24..24),
    :property => :interval,
    :value => :value
  }
]

opts = { 
  :gate => 90,   
  :interval => 7,
  :midi => @output,
  :pattern => Diamond::Pattern["UpDown"],
  :range => 4, 
  :rate => 8,
  :midi_map => map
}

arp = Diamond::Arpeggiator.new(110, opts)



chord = ["C3", "G3", "Bb3", "A4"]

arp << chord
   
arp.start(:focus => true)
