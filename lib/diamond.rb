#!/usr/bin/env ruby
#
# MIDI arpeggiator in Ruby
# (c)2011 Ari Russo and licensed under the Apache 2.0 License
# 
require "forwardable"

require "midi-message"
require "midi-eye"
require "topaz"
require "unimidi"

require "diamond/arpeggiator"
require "diamond/note_event"
require "diamond/pattern"
require "diamond/patterns"
require "diamond/sequencer"

module Diamond
  
  VERSION = "0.0.1"
  
end
