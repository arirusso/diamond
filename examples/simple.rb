#!/usr/bin/env ruby
$:.unshift(File.join("..", "lib"))

# A basic arpeggiator that runs in the foreground

require "diamond"

@output = UniMIDI::Output.gets

options = {
  :gate => 90,
  :interval => 7,
  :midi => @output,
  :pattern => "UpDown",
  :range => 4,
  :rate => 8,
  :tx_channel => 1
}

@clock = Diamond::Clock.new(101)

@arpeggiator = Diamond::Arpeggiator.new(options)

@clock << @arpeggiator

chord = ["C1", "G1", "Bb2", "A3"]

@arpeggiator.add(*chord)

@clock.start(:focus => true)
