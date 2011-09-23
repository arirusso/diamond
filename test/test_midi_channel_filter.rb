#!/usr/bin/env ruby

require 'helper'

class MIDIChannelFilterTest < Test::Unit::TestCase

  include Diamond
  include MIDIMessage
  include TestHelper
  
  def test_input_channel_filter
    arp = Diamond::Arpeggiator.new(175, :channel => 0)
    results = arp.input_midi_channel_filter.process([NoteOn["C4"].new(10, 100)])
    assert_equal(nil, results.first)     
  end
  
  def test_output_channel_filter
    arp = Diamond::Arpeggiator.new(175, :output_channel => 10)
    results = arp.output_midi_channel_filter.process([NoteOn["C4"].new(10, 100)])
    assert_equal(10, results.first.channel)     
    results = arp.output_midi_channel_filter.process([NoteOn["C4"].new(0, 100)])
    assert_equal(0, results.size)
  end
  
end