#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require "diamond"
require "midi-controller"
require "topaz"

kb = MIDIController.new

arp = Diamond::Arpeggiator.new(:steps => 4, :interval => 7)

tempo = Topaz::Tempo.new(138) { arp.step; p arp.current }

tempo.start(:background => true)

kb.capture do |msg| 
  case msg
  when MIDIMessage::NoteOn then arp.add_notes(msg.note)
  when MIDIMessage::NoteOff then arp.remove_notes(msg.note)
  end
end
