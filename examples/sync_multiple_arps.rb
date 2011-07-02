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
  :range => 2, 
  :rate => 8
}

# I gave these different tempos but once they are synced it won't matter

arps = [
  Diamond::Arpeggiator.new(138, opts),
  Diamond::Arpeggiator.new(150, opts),
  Diamond::Arpeggiator.new(160, opts)
]

chord = ["C3", "G3", "Bb3", "A4"]

arps.each_with_index do |arp, i|
  arp << chord
  arp.transpose(i * 12)
  arp.range += i
  arps.first.sync(arp) unless arps.first == arp
  arp.start
  arp.join if arps.last == arp # have the last arp run in a foreground thread
end   
