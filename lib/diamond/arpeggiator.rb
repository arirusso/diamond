module Diamond

  # The arpeggiator core
  class Arpeggiator

    include API::MIDI
    include API::Sequence
    include API::SequenceParameters
    include OSCAccessible

    attr_reader :parameter, :sequence, :sequencer

    DefaultChannel = 0
    DefaultVelocity = 100

    # @param [Hash] options
    # @option options [Fixnum] :rx_channel (or :channel) Only respond to input messages to the given MIDI channel. will operate on all input sources. if not included, or nil the arpeggiator will work in omni mode and respond to all messages
    # @option options [Fixnum] :gate Duration of the arpeggiated notes. The value is a percentage based on the rate.  If the rate is 4, then a gate of 100 is equal to a quarter note. (default: 75) must be 1..500
    # @option options [Fixnum] :interval Increment (pattern) over (interval) scale degrees (range) times.  May be positive or negative. (default: 12)
    # @option options [Array<UniMIDI::Input, UniMIDI::Output>, UniMIDI::Input, UniMIDI::Output] :midi MIDI devices to use
    # @option options [Boolean] :midi_clock_output Should this Arpeggiator output midi clock? (default: false)
    # @option options [Fixnum] :tx_channel Send output messages to the given MIDI channel despite what channel the input notes were intended for.
    # @option options [Fixnum] :pattern_offset Begin on the nth note of the sequence (but not omit any notes). (default: 0)
    # @option options [Pattern] :pattern Compute the contour of the arpeggiated melody
    # @option options [Fixnum] :range Increment the (pattern) over (interval) scale degrees (range) times. Must be positive (abs will be used). (default: 3)
    # @option options [Fixnum] :rate How fast the arpeggios will be played. Must be positive (abs will be used). (default: 8, eighth note.) must be 0..resolution
    # @option options [Fixnum] :resolution Numeric resolution for rhythm (default: 128)   
    def initialize(options = {}, &block)
      devices = MIDIInstrument::Device.partition(options[:midi])
      resolution = options[:resolution] || 128

      @sequence = Sequence.new
      @parameter = SequenceParameters.new(@sequence, resolution, options) { @sequence.mark_changed }
      @sequencer = Sequencer.new
      initialize_midi(devices, options)
      initialize_osc(options) if !!options[:osc_input_port]
    end

    # Add MIDI input notes 
    # @param [Array<MIDIMessage>, MIDIMessage, *MIDIMessage] args
    # @return [Array<MIDIMessage>]
    def add(*args)
      @midi.input << args
    end
    alias_method :<<, :add

    # Add note offs to cancel input
    # @param [Array<MIDIMessage>, MIDIMessage, *MIDIMessage] args
    # @return [Array<MIDIMessage>]
    def remove(*args)
      messages = MIDIInstrument::Message.to_note_offs(*args)
      @midi.input.add(messages.compact)
    end

    # Emit any note off messages that are currently pending in the queue.  The clock triggers this 
    # when stopping or pausing
    # @return [Array<MIDIMessage::NoteOff>]
    def emit_pending_note_offs
      messages = @sequence.pending_note_offs
      @midi.output.puts(*messages)
      messages
    end

    private

    # Initialize MIDI input and output
    # @param [Hash] devices
    # @param [Hash] options
    # @option options [Fixnum] :channel The receive channel (also: :rx_channel)
    # @option options [Fixnum] :tx_channel The transmit channel
    # @return [Boolean]
    def initialize_midi(devices, options = {})
      @midi = MIDIInstrument::Node.new
      initialize_midi_input(devices[:input], options[:rx_channel] || options[:channel])
      initialize_midi_output(devices[:output], options[:tx_channel])
      true
    end

    # Initialize MIDI input, adding and removing notes from the sequence
    # @param [Array<UniMIDI::Input>] inputs
    # @param [Fixnum] channel
    # @return [Boolean]
    def initialize_midi_input(inputs, channel)
      @midi.input.devices.concat(inputs)
      @midi.input.channel = channel
      @midi.input.receive(:class => MIDIMessage::NoteOn) { |event| @sequence.add(event[:message]) }
      @midi.input.receive(:class => MIDIMessage::NoteOff) { |event| @sequence.remove(event[:message]) }
      true
    end

    # Initialize MIDI output, enabling the sequencer to emit notes
    # @param [Array<UniMIDI::Output>] outputs
    # @param [Fixnum] channel
    # @return [Boolean]
    def initialize_midi_output(outputs, channel)
      @midi.output.devices.concat(outputs)
      @midi.output.channel = channel 
      @sequencer.event.perform do |data| 
        @midi.output.puts(data) unless data.empty?
      end
      true
    end

    def initialize_osc(options = {})
      osc_start(:input_port => options[:osc_input_port], :output => options[:osc_output], :map => options[:osc_map], :service_name => options[:name])
    end

  end

end
