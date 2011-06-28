#!/usr/bin/env ruby

require 'helper'

class ApeggiatorTest < Test::Unit::TestCase

  include Diamond
  include MIDIMessage
  include TestHelper
  
  def test_pass_in_source
    input = Config::TestInput
    arp = Diamond::Arpeggiator.new(175, :midi => input)
    assert_equal(Config::TestInput, arp.midi_sources.keys.first)     
  end
  
  def test_add_source
    input = Config::TestInput
    arp = Diamond::Arpeggiator.new(175)
    arp.add_midi_source(input)
    assert_equal(Config::TestInput, arp.midi_sources.keys.first)     
  end

  def test_add_remove_source
    input = Config::TestInput
    arp = Diamond::Arpeggiator.new(175)
    arp.add_midi_source(input)
    assert_equal(Config::TestInput, arp.midi_sources.keys.first)
    arp.remove_midi_source(input)
    assert_equal(nil, arp.midi_sources.keys.first)       
  end
  
end