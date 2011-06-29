#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

#
# this example shows a basic live coding setup
# you would normally enter this code in to irb or some kind of live coding text editor setup
#
# if you run this as a script, it will exit before doing anything
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
  NoteOn["C3"].new(0, 100),
  NoteOn["G3"].new(0, 100),
  NoteOn["Bb3"].new(0, 100),
  NoteOn["A4"].new(0, 100)
]

arp.add(notes)
   
arp.start(:background => true)
