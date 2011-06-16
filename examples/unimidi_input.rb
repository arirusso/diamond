#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require 'diamond'

# first, initialize the MIDI input port
@input = UniMIDI::Input.first.open


