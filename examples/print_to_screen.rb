#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

#
# this a very basic setup, again. set up an arpeggiator and let it run in the foreground
#
# the messages produced will be printed to the screen
#
# there's no MIDI output
#

require "diamond"
require "pp"

opts = { 
  :gate => 90,   
  :interval => 7,
  :midi => $stdout,
  :pattern => Diamond::Pattern["UpDown"],
  :range => 4, 
  :rate => 8
}

arp = Diamond::Arpeggiator.new(175, opts)

chord = ["C4", "E4", "G4"]

arp.add(chord)
   
arp.start(:focus => true)
