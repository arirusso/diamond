#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

# Sync multiple Arpeggiators to each other

require "diamond"

@output = UniMIDI::Output.gets

# Basic options
options = { 
  :gate => 90,   
  :interval => 7,
  :midi => @output,
  :pattern => "UpDown",
  :range => 2, 
  :rate => 8
}

@arpeggiators = [
  Diamond::Arpeggiator.new(options),
  Diamond::Arpeggiator.new(options),
  Diamond::Arpeggiator.new(options)
]

# Vary the output on each arpeggiator
@arpeggiators.each_with_index do |arpeggiator, i|
  arpeggiator.tx_channel = i
  arpeggiator.transpose(i * 12)
  arpeggiator.range += i
end
@arpeggiators.last.rate = 16

# A clock to control all of the arpeggiators
@clock = Diamond::Clock.new(101)
@clock << @arpeggiators

# Some notes..
chord = ["C0", "G0", "Bb0", "A2"]

@arpeggiators.each { |arpeggiator| arpeggiator << chord }

# Start the clock
@clock.start(:focus => true)
