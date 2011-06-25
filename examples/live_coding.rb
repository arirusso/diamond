#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require "diamond"
require "unimidi"

UniMIDI::Output.first.open do |output|

  opts = { 
    :gate => 90, 
    :steps => 4, 
    :interval => 7,
    :rate => 8,
    :resolution => 64
  }

  arp = Diamond::Arpeggiator.new(175, opts) do |msgs|
    data = msgs.map { |msg| msg.to_bytes }.flatten
    output.puts(data) unless data.empty?
  end

  notes = [
    MIDIMessage::NoteOn["C4"].new(0, 100),
    MIDIMessage::NoteOn["E4"].new(0, 100),
    MIDIMessage::NoteOn["G4"].new(0, 100)
  ]

  arp.add(notes)
   
  arp.start(:background => true)

end