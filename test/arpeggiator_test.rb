#!/usr/bin/env ruby

require 'helper'

class ApeggiatorTest < Test::Unit::TestCase

  include Diamond
  include MIDIMessage
  include TestHelper
  
  def test_input_process
    arp = Diamond::Arpeggiator.new(175, :rx_channel => 3)
    msg = NoteOn["C4"].new(10, 100)
    results = arp.send(:process_input, msg)
    assert_equal(nil, results.first)     
    msg2 = NoteOn["C4"].new(3, 100)
    results = arp.send(:process_input, msg2)
    assert_equal(msg2, results.first)     
  end
  
  def test_omni_on
    arp = Diamond::Arpeggiator.new(175, :rx_channel => 3)
    msg = NoteOn["C4"].new(10, 100)
    results = arp.send(:process_input, msg)
    assert_equal(nil, results.first)     
    msg2 = NoteOn["C4"].new(3, 100)
    results = arp.send(:process_input, msg2)
    assert_equal(msg2, results.first) 
    arp.omni_on
    msg3 = NoteOn["C4"].new(2, 100)
    results = arp.send(:process_input, msg3)
    assert_equal(msg3, results.first)            
  end
  
  def test_set_rate
    a = Arpeggiator.new(175, :rate => 8)
    a.rate = 16
    assert_equal(16, a.rate)
  end
  
  def test_set_range
    a = Arpeggiator.new(175, :range => 4)
    a.range += 1
    assert_equal(5, a.range)    
  end
  
  def test_set_interval
    a = Arpeggiator.new(175, :interval => 7)
    a.interval = 12
    assert_equal(12, a.interval)    
  end
  
  def test_set_gate
    a = Arpeggiator.new(175, :gate => 75)
    a.gate = 125
    assert_equal(125, a.gate)    
  end
  
  def test_set_pattern_offset
    a = Arpeggiator.new(175, :pattern_offset => 1)
    a.pattern_offset = 5
    assert_equal(5, a.pattern_offset)    
  end
  
  def test_pass_in_source
    input = $test_device[:input]
    arp = Arpeggiator.new(175, :midi => input)
    assert_equal($test_device[:input], arp.midi_sources.first)     
  end
  
  def test_block
    input = $test_device[:input]
    klass = nil
    Arpeggiator.new(175) do
      klass = self.class
    end
    assert_equal(true, Arpeggiator == klass)    
  end
  
  def test_edit
    input = $test_device[:input]
    klass = nil
    arp = Arpeggiator.new(175) 
    arp.edit do
      klass = self.class
    end
    assert_equal(true, Arpeggiator == klass) 
  end
  
  def test_add_source
    input = $test_device[:input]
    arp = Arpeggiator.new(175)
    arp.add_midi_source(input)
    assert_equal($test_device[:input], arp.midi_sources.first)     
  end

  def test_add_remove_source
    input = $test_device[:input]
    arp = Arpeggiator.new(175)
    arp.add_midi_source(input)
    assert_equal($test_device[:input], arp.midi_sources.first)
    arp.remove_midi_source(input)
    assert_equal(nil, arp.midi_sources.first)       
  end
  
  def test_mute
    arp = Arpeggiator.new(175)    
    assert_equal(false, arp.muted?)       
    arp.mute = true
    assert_equal(true, arp.muted?)
    arp.mute = false
    assert_equal(false, arp.muted?)
    arp.toggle_mute
    assert_equal(true, arp.muted?)
  end
  
end