#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require "diamond"
require "midi-controller"
require "topaz"
require "unimidi"

UniMIDI::Output.first.open do |output|

kb = MIDIController.new

arp = Diamond::Arpeggiator.new(:steps => 4, :interval => 7)

tempo = Topaz::Tempo.new(138) { arp.step; p arp.current; output.puts(arp.current) }

tempo.start(:background => true)

kb.capture do |msg|
  case msg
  when MIDIMessage::NoteOn then arp.add(msg)
  when MIDIMessage::NoteOff then arp.remove(msg)
  end
end

end