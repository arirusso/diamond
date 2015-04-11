#!/usr/bin/env ruby
$:.unshift(File.join("..", "lib"))

# Output MIDI clock messages

require "diamond"

@output = UniMIDI::Output.gets

options = {
  :gate => 90,
  :interval => 7,
  :midi => @output,
  :pattern => "UpDown",
  :range => 4,
  :rate => 8
}

@clock = Diamond::Clock.new(101, :outputs => @output)
@arpeggiator = Diamond::Arpeggiator.new(options)
@clock << @arpeggiator

chord = ["C1", "G1", "Bb2", "A3"]
@arpeggiator.add(*chord)
@clock.start(:focus => true)
