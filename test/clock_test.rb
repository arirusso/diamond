require "helper"

class Diamond::ClockTest < Minitest::Test

  context "Clock" do

    setup do
      @clock = Diamond::Clock.new(120)
    end

    context "Clock#initialize" do

      should "get MIDI output" do
        output = Object.new
        @clock = Diamond::Clock.new(120, :output => output)
        refute_nil @clock.midi_outputs
        refute_empty @clock.midi_outputs
        assert @clock.midi_outputs.include?(output)
      end

    end

    context "Clock#add_midi_output" do

      should "add MIDI output" do
        output = Object.new
        refute @clock.midi_outputs.include?(output)
        @clock.midi_output.devices << output
        refute_nil @clock.midi_outputs
        refute_empty @clock.midi_outputs
        assert @clock.midi_outputs.include?(output)
      end

    end

    context "Clock#remove_midi_output" do

      should "remove MIDI output" do
        output = Object.new
        refute @clock.midi_outputs.include?(output)
        @clock.midi_output.devices << output
        refute_nil @clock.midi_outputs
        refute_empty @clock.midi_outputs
        assert @clock.midi_outputs.include?(output)

        @clock.midi_output.devices.delete(output)
        refute @clock.midi_outputs.include?(output)
      end

    end

    context "Clock#tempo" do

      should "get tempo" do
        assert_equal 120, @clock.tempo
      end

    end

    context "Clock#tempo=" do

      should "set tempo" do
        @clock.tempo = 58
        assert_equal 58, @clock.tempo
      end

    end

  end
end
