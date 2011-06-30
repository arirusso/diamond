#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

#
# this example shows how to create and pass in messages using midi-message
#
# http://github.com/arirusso/midi-message
#
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

arp = Diamond::Arpeggiator.new(175, opts)

include MIDIMessage

with(:channel => 0, :velocity => 120) do |midi|
  notes = [
    midi.note_on("C3"),
    midi.note_on("G3"),
    midi.note_on("Bb3"),
    midi.note_on("A4")
  ]  
end

arp.add(notes)
   
arp.start
