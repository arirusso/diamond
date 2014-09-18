#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

# Create and pass in messages using midi-message objects

require "diamond"

include MIDIMessage

@output = UniMIDI::Output.gets

opts = { 
  :gate => 90,   
  :interval => 7,
  :midi => @output,
  :pattern => "UpDown",
  :range => 4, 
  :rate => 8
}

clock = Diamond::Clock.new(108)
arp = Diamond::Arpeggiator.new(opts)
clock << arp

notes = ["C1", "E1", "A1", "Bb2"]

with(:channel => 0, :velocity => 120) do |midi|
  notes.each do |note|
    arp.add(midi.note_on(note))
  end 
end

clock.start(:focus => true)
