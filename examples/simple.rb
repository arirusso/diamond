#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

#
# A basic arpeggiator that runs in the foreground
#

require "diamond"

@output = UniMIDI::Output.gets

opts = { 
  :gate => 90,   
  :interval => 7,
  :midi => @output,
  :pattern => Diamond::Pattern["UpDown"],
  :range => 4, 
  :rate => 8,
  :tx_channel => 1
}

clock = Diamond::Clock.new(101)

arp = Diamond::Arpeggiator.new(opts)

clock << arp

chord = ["C1", "G1", "Bb2", "A3"]

arp.add(*chord)
   
clock.start(:focus => true)
