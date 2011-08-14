#!/usr/bin/env ruby
#
# MIDI arpeggiator in Ruby
# (c)2011 Ari Russo and licensed under the Apache 2.0 License
# 
require "forwardable"

require "midi-eye"
require "midi-message"
require "musicgrid"
require "topaz"
require "unimidi"

# modules 
require "diamond/midi_channel_filter"

# classes
require "diamond/arpeggiator"
require "diamond/pattern"
require "diamond/arpeggiator_sequence"

require "pattern_presets"

module Diamond
  
  VERSION = "0.0.4"
  
end
