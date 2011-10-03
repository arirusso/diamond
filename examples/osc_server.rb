#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

#
# this is the most basic setup possible
# we just set up an arpeggiator and let it run in the foreground
#

require "diamond"

@output = UniMIDI::Output.use(:first)

map = [
  { 
    :pattern => '/1/fader1',
    :range => (-24..24),
    :property => :interval=
  },
  { 
    :pattern => '/1/fader2',
    :range => (-24..24),
    :property => :transpose
  }
]

opts = { 
  :gate => 90,   
  :interval => 7,
  :midi => @output,
  :pattern => Diamond::Pattern["UpDown"],
  :range => 4, 
  :rate => 8,
  :osc_map => map,
  :osc_receive_port => 8000
}

arp = Diamond::Arpeggiator.new(110, opts)

chord = ["C3", "G3", "Bb3", "A4"]

arp << chord
   
arp.start(:focus => true)
