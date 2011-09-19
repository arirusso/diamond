#!/usr/bin/env ruby

require 'helper'

class ApeggiatorTest < Test::Unit::TestCase

  include Diamond
  include MIDIMessage
  include TestHelper
  
  def test_pass_in_source
    input = Config::TestInput
    arp = Arpeggiator.new(175, :midi => input)
    assert_equal(Config::TestInput, arp.midi_sources.keys.first)     
  end
  
  def test_block
    input = Config::TestInput
    klass = nil
    Arpeggiator.new(175) do
      klass = self.class
    end
    assert_equal(true, Arpeggiator == klass)    
  end
  
  def test_edit
    input = Config::TestInput
    klass = nil
    arp = Arpeggiator.new(175) 
    arp.edit do
      klass = self.class
    end
    assert_equal(true, Arpeggiator == klass) 
  end
  
  def test_add_source
    input = Config::TestInput
    arp = Arpeggiator.new(175)
    arp.add_midi_source(input)
    assert_equal(Config::TestInput, arp.midi_sources.keys.first)     
  end

  def test_add_remove_source
    input = Config::TestInput
    arp = Arpeggiator.new(175)
    arp.add_midi_source(input)
    assert_equal(Config::TestInput, arp.midi_sources.keys.first)
    arp.remove_midi_source(input)
    assert_equal(nil, arp.midi_sources.keys.first)       
  end
  
  def test_mute
    arp = Arpeggiator.new(175)    
    assert_equal(false, arp.muted?)       
    arp.mute
    assert_equal(true, arp.muted?)
    arp.unmute
    assert_equal(false, arp.muted?)
    arp.toggle_mute
    assert_equal(true, arp.muted?)
  end
  
end