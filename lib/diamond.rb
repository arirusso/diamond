#!/usr/bin/env ruby
#
# MIDI arpeggiator in Ruby
# (c)2011 Ari Russo and licensed under the Apache 2.0 License
#

# libs 
require "forwardable"

require "diamond-engine"
require "midi-eye"
require "unimidi"

# classes
require "diamond/arpeggiator"
require "diamond/arpeggiator_sequence"
require "diamond/pattern"

require "pattern_presets"

module Diamond
  
  VERSION = "0.3.0"
  
end
