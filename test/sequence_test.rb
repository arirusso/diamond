require "helper"

class Diamond::SequenceTest < Minitest::Test

  context "Sequence" do

    setup do
      @sequence = Diamond::Sequence.new
      @params = Diamond::SequenceParameters.new(@sequence, 16) { @sequence.mark_changed }
    end

    context "#update" do

      should "convert notes to events" do
        notes = [
          MIDIMessage::NoteOn["C4"].new(0, 100),
          MIDIMessage::NoteOn["E4"].new(0, 100),
          MIDIMessage::NoteOn["G4"].new(0, 100)
        ]
        @sequence.add(notes)
        schema = @sequence.send(:update)
        assert_equal(24, schema.length)
        assert_equal(MIDIInstrument::NoteEvent, schema[0][0].class)
        assert_equal(MIDIInstrument::NoteEvent, schema[4][0].class)
        assert_equal(MIDIInstrument::NoteEvent, schema[8][0].class)
        assert_equal([], schema[1])
        assert_equal([], schema[5])
        assert_equal([], schema[9])
      end

    end

  end

end
