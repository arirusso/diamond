#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

#
# this example is the same as the "simple.rb" one, except that it syncs to MIDI clock
# from a unimidi input
#
# we just set up an arpeggiator and let it run in the foreground
#
#

require "diamond"

@input = UniMIDI::Input.gets
@output = UniMIDI::Output.gets

opts = { 
  :gate => 90,   
  :interval => 7,
  :midi => @output,
  :pattern => Diamond::Pattern["UpDown"],
  :range => 4, 
  :rate => 8
}

arp = Diamond::Arpeggiator.new(@input, opts)

chord = ["C3", "G3", "Bb3", "A4"]

arp.add(chord)
   
arp.start(:focus => true)

# the arpeggiator will actually start when it begins receiving clock messages