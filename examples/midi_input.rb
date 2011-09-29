#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

#
# this example shows how to enter notes using MIDI input
#

require "diamond"

#
# you will want to select the MIDI input that your controller or other device is connected to
#
# here is an example that explains a bit more about selecting devices with unimidi:
# http://github.com/arirusso/unimidi/blob/master/examples/select_a_device.rb
#
@input = UniMIDI::Input.use(:first)
@output = UniMIDI::Output.use(:first)

opts = { 
  :gate => 90,   
  :interval => 7,
  :midi => [@output, @input],
  :pattern => Diamond::Pattern["UpDown"],
  :range => 4, 
  :rate => 8
}

arp = Diamond::Arpeggiator.new(140, opts)

# normally by default the arpeggiator will be in "omni mode" or in other words, accept notes
# from all MIDI channels

# to tell the arpeggiator to only look at a single channel, just set a channel

arp.input_channel = 0 

# you can also call arp.channel = nil to return it to omni mode

# (Diamond does not respond to MIDI Omni On/Off messages)
   
arp.start(:focus => true)

# now when you play notes in to the input, they will be sent to the arpeggiator the same way
# we used arp.add(chord in the simple example)
