#!/usr/bin/env ruby

require 'helper'

class EventSequencerTest < Test::Unit::TestCase

  include MusicGrid
  include MIDIMessage
  include TestHelper
    
  def test_rest_when
    output = Config::TestOutput
    arp = Diamond::Arpeggiator.new(175, :midi => output)
    arp.rest_when { |state| state.pointer == 0 }
    assert_equal(true, arp.rest?)
  end
  
end