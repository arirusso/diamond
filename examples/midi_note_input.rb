#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

# Enter notes using MIDI input


require "diamond"

# Select the MIDI input that your controller or other device is connected to
#
# here is an example that explains a bit more about selecting devices with unimidi:
# http://github.com/arirusso/unimidi/blob/master/examples/select_a_device.rb

@input = UniMIDI::Input.gets
@output = UniMIDI::Output.gets

options = { 
  :gate => 20,   
  :interval => 7,
  :midi => [@output, @input],
  #:midi_debug => true, # uncomment this for debug output about MIDI messages in the console
  :pattern => "UpDown",
  :range => 4, 
  :rate => 8
}

@clock = Diamond::Clock.new(101)
@arpeggiator = Diamond::Arpeggiator.new(options)
@clock << @arpeggiator

# By default the arpeggiator will be in "omni mode", reacting to notes received from all MIDI channels

# To only look at a single channel, set the input channel via Arpeggiator#rx_channel=
# Can also be passed in to the Arpeggiator constructor via the :rx_channel option

@arpeggiator.rx_channel = 0 

# You can then call arp.rx_channel = nil or arp.omni_on to return it to omni mode
# (Diamond does not respond to MIDI Omni On/Off messages)

# It's also possible to set the channel that the arpeggiator will output on

@arpeggiator.tx_channel = 1

@clock.start(:focus => true)

# When you play notes, they will be sent to the arpeggiator the same way 
# Arpeggiator#add is used in most of the other examples
