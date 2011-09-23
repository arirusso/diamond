#!/usr/bin/env ruby
#
# MIDI arpeggiator in Ruby
# (c)2011 Ari Russo and licensed under the Apache 2.0 License
#
$:.unshift File.join( File.dirname( __FILE__ ), '../../inst/lib')
# libs 
require "forwardable"

require "inst"
require "midi-eye"
require "unimidi"

# classes
require "diamond/arpeggiator"
require "diamond/midi_channel_filter"
require "diamond/pattern"
require "diamond/arpeggiator_sequence"

require "pattern_presets"

module Diamond
  
  VERSION = "0.0.6"
  
end
