#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

#
# this example shows how to enter notes using MIDI input
#

require "diamond"

include MIDIMessage

@input = UniMIDI::Input.first.open
@output = UniMIDI::Output.first.open

opts = { 
  :gate => 90,   
  :interval => 7,
  :midi => [@output, @input],
  :pattern => Diamond::Pattern["UpDown"],
  :range => 4, 
  :rate => 8
}

arp = Diamond::Arpeggiator.new(175, opts)

# normally by the fault the arpeggiator will be in "omni mode" or in other words, accept notes
# from all MIDI channels

# to tell the arpeggiator to only look at a single channel, just set a channel

arp.channel = 0 

# you can also call arp.channel = nil to return it to omni mode

# (Diamond does not respond to MIDI Omni On/Off messages)
   
arp.start

# now when you play notes in to the input, they will be sent to the arpeggiator the same way
# we used arp.add(chord in the simple example)