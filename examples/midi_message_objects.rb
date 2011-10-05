#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

#
# this example shows how to create and pass in messages using midi-message
#
# http://github.com/arirusso/midi-message
#
#

require "diamond"

@output = UniMIDI::Output.gets

opts = { 
  :gate => 90,   
  :interval => 7,
  :midi => @output,
  :pattern => Diamond::Pattern["UpDown"],
  :range => 4, 
  :rate => 8
}

arp = Diamond::Arpeggiator.new(108, opts)

include MIDIMessage

notes = ["C1", "E1", "A1", "Bb2"]

with(:channel => 0, :velocity => 120) do |midi|
  notes.each do |note|
    arp.add(midi.note_on(note))
  end 
end

arp.start(:focus => true)
