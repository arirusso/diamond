#!/usr/bin/env ruby

require 'helper'

class ArpeggiatorSequenceTest < Test::Unit::TestCase

  include Diamond
  include MIDIMessage
  include Inst
  include TestHelper
  
  def test_set_rate
    a = ArpeggiatorSequence.new(16, :rate => 8)
    a.rate = 16
    assert_equal(16, a.rate)
  end
  
  def test_set_range
    a = ArpeggiatorSequence.new(16, :range => 4)
    a.range += 1
    assert_equal(5, a.range)    
  end
  
  def test_set_interval
    a = ArpeggiatorSequence.new(16, :interval => 7)
    a.interval = 12
    assert_equal(12, a.interval)    
  end
  
  def test_set_gate
    a = ArpeggiatorSequence.new(16, :gate => 75)
    a.gate = 125
    assert_equal(125, a.gate)    
  end
  
  def test_set_pattern_offset
    a = ArpeggiatorSequence.new(16, :pattern_offset => 1)
    a.pattern_offset = 5
    assert_equal(5, a.pattern_offset)    
  end
  
  def test_sequence
    seq = ArpeggiatorSequence.new(16)
    notes = [
      NoteOn["C4"].new(0, 100),
      NoteOn["E4"].new(0, 100),
      NoteOn["G4"].new(0, 100)
    ]
    seq.add(notes)
    llseq = seq.send(:update_sequence)
    assert_equal(24, llseq.length)
    assert_equal(Event::Note, llseq[0][0].class)
    assert_equal(Event::Note, llseq[4][0].class)
    assert_equal(Event::Note, llseq[8][0].class)
    assert_equal([], llseq[1])
    assert_equal([], llseq[5])
    assert_equal([], llseq[9])
  end
  
  def test_constrain
    seq = ArpeggiatorSequence.new(128, :rate => 500)
    assert_equal(seq.rate, 128)
  end
  
end