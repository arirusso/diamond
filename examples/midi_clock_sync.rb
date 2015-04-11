#!/usr/bin/env ruby
$:.unshift(File.join("..", "lib"))

# This example is the same as the "simple.rb", except that it syncs to MIDI clock
# from a unimidi input

require "diamond"

@input = UniMIDI::Input.gets
@output = UniMIDI::Output.gets

options = {
  :gate => 90,
  :interval => 7,
  :midi => @output,
  :pattern => "UpDown",
  :range => 4,
  :rate => 8
}

@clock = Diamond::Clock.new(@input)
@arpeggiator = Diamond::Arpeggiator.new(options)
@clock << @arpeggiator

chord = ["C1", "G1", "Bb2", "A3"]
@arpeggiator.add(*chord)
@clock.start(:focus => true)
