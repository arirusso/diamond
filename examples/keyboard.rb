#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require "diamond"
require "midi-controller"
require "unimidi"

UniMIDI::Output.first.open do |output|

kb = MIDIController.new

arp = Diamond::Arpeggiator.new(:steps => 4, :interval => 7)

tempo = Topaz::Tempo.new(138) do 
  arp.step
  data = arp.messages_as_bytes
  p data 
  output.puts(data) unless data.empty?
end

#opts = { 
#  :gate => 128, 
#  :steps => 4, 
#  :interval => 7, 
#  :background => true 
#}
#
#arpeggiator = Diamond.new(138, opts) do |msgs|
#  data = msgs.map { |msg| msg.to_bytes }
#  p data 
#  output.puts(data) unless data.empty?
#end 

tempo.start(:background => true)

kb.capture do |msg|
  case msg
    when MIDIMessage::NoteOn then arp.add(msg)
    when MIDIMessage::NoteOff then arp.remove(msg)
  end
end

end