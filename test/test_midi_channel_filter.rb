#!/usr/bin/env ruby

require 'helper'

class MIDIChannelFilterTest < Test::Unit::TestCase

  include Diamond
  include MIDIMessage
  include TestHelper
  
  def test_input_channel_filter
    arp = Diamond::Arpeggiator.new(175, :channel => 0)
    results = arp.input_channel_filter([NoteOn["C4"].new(10, 100)])
    assert_equal(nil, results.first)     
  end
  
  def test_output_channel_filter
    arp = Diamond::Arpeggiator.new(175, :output_channel => 0)
    results = arp.output_channel_filter([NoteOn["C4"].new(10, 100)])
    assert_equal(0, results.first.channel)     
  end
  
end