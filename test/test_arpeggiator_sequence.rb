#!/usr/bin/env ruby

require 'helper'

class ArpeggiatorSequenceTest < Test::Unit::TestCase

  include Diamond
  include MIDIMessage
  include Inst
  include TestHelper
  
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
    assert_equal(MIDINoteEvent, llseq[0][0].class)
    assert_equal(MIDINoteEvent, llseq[4][0].class)
    assert_equal(MIDINoteEvent, llseq[8][0].class)
    assert_equal([], llseq[1])
    assert_equal([], llseq[5])
    assert_equal([], llseq[9])
  end
  
  def test_constrain
    seq = ArpeggiatorSequence.new(128, :rate => 500)
    assert_equal(seq.rate, 128)
  end
  
end