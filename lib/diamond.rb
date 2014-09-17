#
# Diamond
#
# MIDI arpeggiator in Ruby
# (c)2011-2014 Ari Russo and licensed under the Apache 2.0 License
#
$:.unshift File.join( File.dirname( __FILE__ ), '../../sequencer/lib')
$:.unshift File.join( File.dirname( __FILE__ ), '../../midi-instrument/lib')

# libs 
require "forwardable"
require "midi-instrument"
require "osc-access"
require "sequencer"
require "unimidi"

# modules
require "diamond/api"

# classes
require "diamond/arpeggiator"
require "diamond/arpeggiator_sequence"
require "diamond/clock"
require "diamond/pattern"
require "diamond/process_chain"

# config
require "pattern_presets"

module Diamond
  
  VERSION = "0.4.3"
  
end
