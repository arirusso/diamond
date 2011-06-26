#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require "diamond"
require "unimidi"

include MIDIMessage

output = UniMIDI::Output.first.open

opts = { 
  :gate => 90, 
  :steps => 4, 
  :interval => 7,
  :midi => output,
  :rate => 8,
  :resolution => 64
}

arp = Diamond::Arpeggiator.new(175, opts)

notes = [
  NoteOn["C4"].new(0, 100),
  NoteOn["E4"].new(0, 100),
  NoteOn["G4"].new(0, 100)
]

arp.add(notes)
   
arp.start(:background => true)
