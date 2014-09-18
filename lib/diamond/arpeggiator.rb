module Diamond

  # The arpeggiator core
  class Arpeggiator

    include API::MIDI
    include API::Sequence
    include API::SequenceParameters

    attr_reader :parameter, :sequence, :sequencer

    # @param [Hash] options
    # @option options [Fixnum] :rx_channel (or :channel) Only respond to input messages to the given MIDI channel. will operate on all input sources. if not included, or nil the arpeggiator will work in omni mode and respond to all messages
    # @option options [Fixnum] :gate Duration of the arpeggiated notes. The value is a percentage based on the rate.  If the rate is 4, then a gate of 100 is equal to a quarter note. (default: 75) must be 1..500
    # @option options [Fixnum] :interval Increment (pattern) over (interval) scale degrees (range) times.  May be positive or negative. (default: 12)
    # @option options [Array<UniMIDI::Input, UniMIDI::Output>, UniMIDI::Input, UniMIDI::Output] :midi MIDI devices to use
    # @option options [Array<Hash>] :midi_control A user-defined mapping of MIDI cc to arpeggiator params
    # @option options [Fixnum] :tx_channel Send output messages to the given MIDI channel despite what channel the input notes were intended for.
    # @option options [Fixnum] :pattern_offset Begin on the nth note of the sequence (but not omit any notes). (default: 0)
    # @option options [String, Pattern] :pattern Computes the contour of the arpeggiated melody.  Can be the name of a pattern or a pattern object.
    # @option options [Fixnum] :range Increment the (pattern) over (interval) scale degrees (range) times. Must be positive (abs will be used). (default: 3)
    # @option options [Fixnum] :rate How fast the arpeggios will be played. Must be positive (abs will be used). (default: 8, eighth note.) must be 0..resolution
    # @option options [Fixnum] :resolution Numeric resolution for rhythm (default: 128)   
    # @option options [Hash] :osc_control A user-defined map of OSC addresses and properties to arpeggiator params
    # @option options [Fixnum] :osc_port The port to listen for OSC on
    def initialize(options = {}, &block)
      devices = MIDIInstrument::Device.partition(options[:midi])
      resolution = options[:resolution] || 128

      @sequence = Sequence.new
      @parameter = SequenceParameters.new(@sequence, resolution, options) { @sequence.mark_changed }
      @sequencer = Sequencer.new

      initialize_midi(devices, options)
      initialize_osc_parameter_control(options[:osc_control], :port => options[:port]) if !options[:osc_control].nil?
    end

    private

    def initialize_midi(devices, options = {})
      @midi = MIDI.new(devices, options)
      @midi.enable_output(@sequencer)
      @midi.enable_note_control(@sequence)
      @midi.enable_parameter_control(@parameter, options[:midi_control]) if !options[:midi_control].nil?
    end

    # @param [Hash] options
    # @option options [Hash] :osc_map A map of OSC addresses and properties
    # @option options [Fixnum] :osc_port The port to listen for OSC on
    def initialize_osc_parameter_control(map, options = {})
      @osc_controller = OSC::Controller.new(self, map, :port => options[:port]) 
      @osc_controller.start
    end

    # Emit any note off messages that are currently pending in the queue.  The clock triggers this 
    # when stopping or pausing
    # @return [Array<MIDIMessage::NoteOff>]
    def emit_pending_note_offs
      messages = @sequence.pending_note_offs
      @midi.output.puts(*messages)
      messages
    end

  end

end
