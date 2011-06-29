#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

#
# this is the most basic setup possible
# we just set up an arpeggiator and let it run in the foreground
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

notes = [
  NoteOn["C4"].new(0, 100),
  NoteOn["E4"].new(0, 100),
  NoteOn["G4"].new(0, 100)
]

arp.add(notes)
   
arp.start
