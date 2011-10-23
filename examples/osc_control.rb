#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

#
# this is the most basic setup possible
# we just set up an arpeggiator and let it run in the foreground
#

require "diamond"

@output = UniMIDI::Output.gets

map = {
  "/1/fader1" => { 
    :translate => -24..24,
    :action => Proc.new { |arpeggiator, val| arpeggiator.interval = val }
  },
  "/1/fader2" => { 
    :translate => -24..24,
    :action => Proc.new { |arpeggiator, val| arpeggiator.transpose = val }
  }
}

opts = { 
  :gate => 90,   
  :interval => 7,
  :midi => @output,
  :pattern => Diamond::Pattern["UpDown"],
  :range => 4, 
  :rate => 8,
  :resolution => 128,
  :osc_map => map,
  :osc_input_port => 8000
}

arp = Diamond::Arpeggiator.new(110, opts)

chord = ["C3", "G3", "Bb3", "A4"]

arp << chord
   
arp.start(:focus => true)
