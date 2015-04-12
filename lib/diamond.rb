#
# Diamond
# MIDI arpeggiator in Ruby
#
# (c)2011-2015 Ari Russo
# Apache 2.0 License
#

# libs
require "forwardable"
require "midi-instrument"
require "midi-message"
require "osc-ruby"
require "osc-ruby/em_server"
require "scale"
require "sequencer"
require "topaz"
require "unimidi"

# modules
require "diamond/api"

# classes
require "diamond/arpeggiator"
require "diamond/clock"
require "diamond/midi"
require "diamond/osc"
require "diamond/pattern"
require "diamond/sequence"
require "diamond/sequence_parameters"

module Diamond

  VERSION = "0.5.9"

end
