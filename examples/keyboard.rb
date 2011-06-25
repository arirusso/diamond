#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require "diamond"
require "midi-controller"
require "unimidi"

UniMIDI::Output.first.open do |output|

#kb = MIDIController.new

opts = { 
  :gate => 90, 
  :steps => 4, 
  :interval => 7,
  :rate => 8,
  :resolution => 64
}

arp = Diamond::Arpeggiator.new(175, opts) do |msgs|
  data = msgs.map { |msg| msg.to_bytes }.flatten
  p data 
  output.puts(data) unless data.empty?
end

notes = [
  MIDIMessage::NoteOn["C4"].new(0, 100),
  MIDIMessage::NoteOn["E4"].new(0, 100),
  MIDIMessage::NoteOn["G4"].new(0, 100)
]
   
arp.start
#(:background => true)

#kb.capture do |msg|
#  case msg
#    when MIDIMessage::NoteOn then arp.add(msg)
#    when MIDIMessage::NoteOff then arp.remove(msg)
#  end
#end

end