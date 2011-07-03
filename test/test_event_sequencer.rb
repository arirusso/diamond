#!/usr/bin/env ruby

require 'helper'

class EventSequencerTest < Test::Unit::TestCase

  include Diamond
  include MIDIMessage
  include TestHelper
    
  def test_rest_when
    output = Config::TestOutput
    arp = Diamond::Arpeggiator.new(175, :midi => output)
    arp.rest_when { |state| state.step == 0 }
    assert_equal(true, arp.rest?)
  end
  
  def test_reset_when
    output = Config::TestOutput
    arp = Diamond::Arpeggiator.new(175, :midi => output)
    arp.reset_when { |state| state.step == 3 }
  end
  
end