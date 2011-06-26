#!/usr/bin/env ruby

require 'helper'

class PatternTest < Test::Unit::TestCase

  include Diamond
  include MIDIMessage
  include TestHelper
  
  def test_sequence
    seq = Sequencer.new(16)
    notes = [
      NoteOn["C4"].new(0, 100),
      NoteOn["E4"].new(0, 100),
      NoteOn["G4"].new(0, 100)
    ]
    seq.add(notes)
    llseq = seq.send(:update_sequence)
    assert_equal(48, llseq.length)
    assert_equal(NoteEvent, llseq[0][0].class)
    assert_equal(NoteEvent, llseq[4][0].class)
    assert_equal(NoteEvent, llseq[8][0].class)
    assert_equal([], llseq[1])
    assert_equal([], llseq[5])
    assert_equal([], llseq[9])
  end
  
end