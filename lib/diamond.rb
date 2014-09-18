#
# Diamond
#
# MIDI arpeggiator in Ruby
# (c)2011-2014 Ari Russo and licensed under the Apache 2.0 License
#

# libs 
require "forwardable"
require "midi-instrument"
require "midi-message"
require "scale"
require "sequencer"
require "topaz"
require "unimidi"

# modules
require "diamond/api"

# classes
require "diamond/arpeggiator"
require "diamond/clock"
require "diamond/osc/controller"
require "diamond/pattern"
require "diamond/sequence"
require "diamond/sequence_parameters"

module Diamond
  
  VERSION = "0.4.3"
  
end
