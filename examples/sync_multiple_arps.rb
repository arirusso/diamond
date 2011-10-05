#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

#
# this example shows the various ways to sync multiple Arpeggiators to each other
#

require "diamond"

@output = UniMIDI::Output.gets

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
  Diamond::Arpeggiator.new(109, opts),
  Diamond::Arpeggiator.new(100, opts),
  Diamond::Arpeggiator.new(90, opts)
]

chord = ["C0", "G0", "Bb0", "A2"]

arps.last.rate = 16

arps.each_with_index do |arp, i|
  arp << chord
  arp.transpose(i * 12)
  arp.range += i
  arps.first.sync(arp) unless arps.first == arp
  arp.start
  arp.join if arps.last == arp # have the last arp run in a foreground thread
end   
