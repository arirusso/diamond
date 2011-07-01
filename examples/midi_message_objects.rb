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

arp = Diamond::Arpeggiator.new(138, opts)

include MIDIMessage

notes = ["C3", "E3", "A3", "Bb4"]

with(:channel => 0, :velocity => 120) do |midi|
  notes.each do |note|
    arp.add(midi.note_on(note))
  end 
end

arp.start
