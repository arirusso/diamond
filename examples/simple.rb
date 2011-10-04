#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

#
# this is the most basic setup possible
# we just set up an arpeggiator and let it run in the foreground
#

require "diamond"

@output = UniMIDI::Output.gets

opts = { 
  :gate => 90,   
  :interval => 7,
  :midi => @output,
  :pattern => Diamond::Pattern["UpDown"],
  :range => 4, 
  :rate => 8
}

arp = Diamond::Arpeggiator.new(139, opts)

chord = ["C1", "G1", "Bb2", "A3"]

arp.add(chord)
   
arp.start(:focus => true)
