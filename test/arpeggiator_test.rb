require "helper"

class Diamond::ApeggiatorTest < Test::Unit::TestCase
    
  def test_omni_on
    arp = Diamond::Arpeggiator.new(:rx_channel => 3)
    message = MIDIMessage::NoteOn["C4"].new(10, 100)
    arp.add(message)
    assert_empty arp.sequence.input_queue

    message2 = MIDIMessage::NoteOn["C4"].new(3, 100)
    arp.add(message2)
    arp.sequence.input_queue.expects(:concat).once.with([message2])

    arp.omni_on
    message3 = MIDIMessage::NoteOn["C4"].new(2, 100)
    arp.add(message3)
    arp.sequence.input_queue.expects(:concat).once.with([message3])       
  end
  
  def test_set_rate
    a = Diamond::Arpeggiator.new(:rate => 8)
    a.rate = 16
    assert_equal(16, a.rate)
  end
  
  def test_set_range
    a = Diamond::Arpeggiator.new(:range => 4)
    a.range += 1
    assert_equal(5, a.range)    
  end
  
  def test_set_interval
    a = Diamond::Arpeggiator.new(:interval => 7)
    a.interval = 12
    assert_equal(12, a.interval)    
  end
  
  def test_set_gate
    a = Diamond::Arpeggiator.new(:gate => 75)
    a.gate = 125
    assert_equal(125, a.gate)    
  end
  
  def test_set_pattern_offset
    a = Diamond::Arpeggiator.new(:pattern_offset => 1)
    a.pattern_offset = 5
    assert_equal(5, a.pattern_offset)    
  end
  
  def test_pass_in_source
    input = $test_device[:input]
    arp = Diamond::Arpeggiator.new(:midi => input)
    assert_equal($test_device[:input], arp.midi_sources.first)     
  end
      
  def test_add_source
    input = $test_device[:input]
    arp = Diamond::Arpeggiator.new
    arp.add_midi_source(input)
    assert_equal($test_device[:input], arp.midi_sources.first)     
  end

  def test_add_remove_source
    input = $test_device[:input]
    arp = Diamond::Arpeggiator.new
    arp.add_midi_source(input)
    assert_equal($test_device[:input], arp.midi_sources.first)
    arp.remove_midi_source(input)
    assert_equal(nil, arp.midi_sources.first)       
  end
  
  def test_mute
    arp = Diamond::Arpeggiator.new 
    assert_equal(false, arp.muted?)       
    arp.mute = true
    assert_equal(true, arp.muted?)
    arp.mute = false
    assert_equal(false, arp.muted?)
    arp.toggle_mute
    assert_equal(true, arp.muted?)
  end
  
end
