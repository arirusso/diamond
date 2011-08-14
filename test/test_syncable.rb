#!/usr/bin/env ruby

require 'helper'

class SyncableTest < Test::Unit::TestCase

  include Diamond
  include MIDIMessage
  include TestHelper

  def test_sync
    arp = Diamond::Arpeggiator.new(175)
    arp2 = Diamond::Arpeggiator.new(175)
    arp.start
    arp2.start
    arp.add("C3")
    arp.sync(arp2)
    sleep(1)
    assert_equal(arp2, arp.sync_set.first)
  end
  
  def test_sync_and_unsync    
    arp = Diamond::Arpeggiator.new(175)
    arp2 = Diamond::Arpeggiator.new(175)
    arp.start
    arp2.start
    arp.add("C3")
    arp.sync(arp2)
    sleep(1)
    assert_equal(arp2, arp.sync_set.first) 
    arp.unsync(arp2)
    assert_equal(nil, arp.sync_set.first)
  end    
  
end