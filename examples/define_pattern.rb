#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require "diamond"

include MIDIMessage

opts = { 
  :gate => 90, 
  :range => 4, 
  :interval => 7,
  :midi => UniMIDI::Output.first.open,
  :rate => 8
}

arp = Diamond::Arpeggiator.new(175, opts)

notes = [
  NoteOn["C4"].new(0, 100),
  NoteOn["E4"].new(0, 100),
  NoteOn["G4"].new(0, 100)
]

arp.add(notes)

#
# the Pattern Proc should return a set of scale degrees.
#  for example, given (3, 7) the "Up" pattern will return [0, 7, 14, 21]
#
arp.pattern = Diamond::Pattern.new("Up") do |r, i|
  a = []
  0.upto(r) { |n| a << (n * i) }
  a
end
   
arp.start
