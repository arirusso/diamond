#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

#
# this example shows the various ways to sync multiple Arpeggiators to each other
#

require "diamond"

@output = UniMIDI::Output.first.open

opts = { 
  :gate => 90,   
  :interval => 7,
  :midi => @output,
  :pattern => Diamond::Pattern["UpDown"],
  :range => 4, 
  :rate => 8
}

# I gave these different tempos but once they are synced it won't matter

arp = Diamond::Arpeggiator.new(138, opts)
arp2 = Diamond::Arpeggiator.new(150, opts)
arp3 = Diamond::Arpeggiator.new(160, opts)

chord = ["C3", "G3", "Bb3", "A4"]

arp.add(chord)
   
arp.start(:background => true)
