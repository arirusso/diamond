#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require "diamond"

include MIDIMessage

opts = { 
  :gate => 90, 
  :range => 4, 
  :interval => 7,
  :midi => UniMIDI::Output.first.open,
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
