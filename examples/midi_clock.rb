#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

#
# this example is the same as the "simple.rb" one, except that it syncs to MIDI clock
# from a unimidi input
#
# we just set up an arpeggiator and let it run in the foreground
#
# clock is always sent from Diamond to any MIDI outputs that are passed in
#

require "diamond"

@input = UniMIDI::Input.first.open
@output = UniMIDI::Output.first.open

opts = { 
  :gate => 90,   
  :interval => 7,
  :midi => @output,
  :pattern => Diamond::Pattern["UpDown"],
  :range => 4, 
  :rate => 8
}

arp = Diamond::Arpeggiator.new(@input, opts)

include MIDIMessage

notes = [
  NoteOn["C4"].new(0, 100),
  NoteOn["E4"].new(0, 100),
  NoteOn["G4"].new(0, 100)
]

arp.add(notes)
   
arp.start

# the arpeggiator will actually start when it begins receiving clock messages