#!/usr/bin/env ruby

require 'helper'

class SequencerCallbacksTest < Test::Unit::TestCase

  include Inst
  include MIDIMessage
  include TestHelper
    
  def test_rest_when
    output = $test_device[:output]
    arp = Diamond::Arpeggiator.new(175, :midi => output)
    arp.rest_when { |state| state.pointer == 0 }
    assert_equal(true, arp.rest?)
  end
  
end