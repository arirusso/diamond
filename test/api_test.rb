require "helper"

class Diamond::APITest < Test::Unit::TestCase

  context "API" do

    context "MIDI" do

      context "#omni_on" do

        setup do
          @messages = [
            MIDIMessage::NoteOn["C4"].new(10, 100),
            MIDIMessage::NoteOn["C4"].new(3, 100),
            MIDIMessage::NoteOn["C4"].new(2, 100)
          ]
          @arpeggiator = Diamond::Arpeggiator.new(:rx_channel => 3)
        end

        should "not acknowledge message with wrong rx channel" do
          @arpeggiator.sequence.expects(:add).never
          @arpeggiator.add(@messages[0])
          assert_empty @arpeggiator.sequence.instance_variable_get("@input_queue")
        end

        should "acknowledge message with rx channel" do
          @arpeggiator.sequence.expects(:add).once
          @arpeggiator.add(@messages[1])
          @arpeggiator.sequence.instance_variable_get("@input_queue").expects(:concat).once.with([@messages[1]])
        end

        should "with omni on, acknowledge any rx channel" do
          @arpeggiator.sequence.expects(:add).once
          @arpeggiator.omni_on
          @arpeggiator.add(@messages[2])
          @arpeggiator.sequence.instance_variable_get("@input_queue").expects(:concat).once.with([@messages[2]]) 
        end

      end

      context "#add_midi_source" do

        setup do
          @input = $test_device[:input]
          @arpeggiator = Diamond::Arpeggiator.new
          refute @arpeggiator.midi_sources.include?(@input)
        end

        should "add a midi source" do
          @arpeggiator.add_midi_source(@input)
          assert_not_empty @arpeggiator.midi_sources
          assert @arpeggiator.midi_sources.include?(@input)
        end

      end

      context "#remove_midi_source" do

        setup do
          @input = $test_device[:input]
          @arpeggiator = Diamond::Arpeggiator.new
          @arpeggiator.add_midi_source(@input)
          assert_not_empty @arpeggiator.midi_sources
          assert @arpeggiator.midi_sources.include?(@input)
        end

        should "remove a midi source" do
          @arpeggiator.remove_midi_source(@input)
          refute @arpeggiator.midi_sources.include?(@input)
        end

      end

      context "#mute" do

        setup do
          @arpeggiator = Diamond::Arpeggiator.new
        end

        should "mute the arpeggiator" do
          refute @arpeggiator.muted?     
          @arpeggiator.mute = true
          assert @arpeggiator.muted?
          @arpeggiator.mute = false
          refute @arpeggiator.muted?
          @arpeggiator.toggle_mute
          assert @arpeggiator.muted?
        end

      end

    end

    context "SequenceParameters" do

      setup do
        @arpeggiator = Diamond::Arpeggiator.new
      end

      context "#rate=" do

        should "set the rate" do
          assert_not_equal 16, @arpeggiator.rate
          @arpeggiator.rate = 16
          assert_equal 16, @arpeggiator.rate
        end

      end

      context "#range=" do

        should "set the range" do
          @arpeggiator.range = 4
          assert_equal 4, @arpeggiator.range
          @arpeggiator.range += 1
          assert_equal 5, @arpeggiator.range 
        end

      end

      context "#interval=" do

        should "set the interval" do
          assert_not_equal 7, @arpeggiator.interval
          @arpeggiator.interval = 7
          assert_equal 7, @arpeggiator.interval 
        end

      end

      context "#gate=" do

        should "set the gate" do
          assert_not_equal 125, @arpeggiator.gate
          @arpeggiator.gate = 125
          assert_equal 125, @arpeggiator.gate 
        end

      end

      context "#pattern_offset=" do

        should "set the offset" do
          assert_not_equal 5, @arpeggiator.pattern_offset
          @arpeggiator.pattern_offset = 5
          assert_equal 5, @arpeggiator.pattern_offset
        end

      end

    end

  end

end
