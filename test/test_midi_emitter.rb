#!/usr/bin/env ruby

require 'helper'

class MIDIEmitterTest < Test::Unit::TestCase

  include Diamond
  include MIDIMessage
  include TestHelper
    
  def test_add_destination
    output = Config::TestOutput
    arp = Diamond::Arpeggiator.new(175, :midi => output)
    assert_equal(Config::TestOutput, arp.midi_destinations.first)
  end
  
  def test_add_remove_destination    
    output = Config::TestOutput
    arp = Diamond::Arpeggiator.new(175, :midi => output)
    assert_equal(Config::TestOutput, arp.midi_destinations.first)
    arp.remove_midi_destinations(output)
    assert_equal(nil, arp.midi_destinations.first)       
  end
  
end