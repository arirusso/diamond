#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require "diamond"
require "midi-controller"

UniMIDI::Output.first.open do |output|

  kb = MIDIController.new

  opts = { 
    :gate => 90, 
    :range => 4, 
    :interval => 12,
    :midi => output,
    :pattern => Diamond::Pattern["Up"],
    :rate => 8,
    :resolution => 32
  } 

  arp = Diamond::Arpeggiator.new(150, opts) do |msgs| 
    p msgs.map { |m| m.to_bytes }
  end 
   
  arp.start(:background => true)

  kb.capture do |msg|
    case msg
      when MIDIMessage::NoteOn then arp.add(msg)
      when MIDIMessage::NoteOff then arp.remove(msg)
    end
  end

end