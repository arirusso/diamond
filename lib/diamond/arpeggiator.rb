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

      initialize_midi_devices(devices, options)
      initialize_midi_output
      initialize_midi_note_control
      initialize_midi_parameter_control(options[:midi_control]) if !options[:midi_control].nil?
      initialize_osc_parameter_control(options[:osc_control], :port => options[:port]) if !options[:osc_control].nil?
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

    private

    # @param [Hash] options
    # @option options [Hash] :osc_map A map of OSC addresses and properties
    # @option options [Fixnum] :osc_port The port to listen for OSC on
    def initialize_osc_parameter_control(map, options = {})
      @osc_controller = OSC::Controller.new(self, map, :port => options[:port]) 
      @osc_controller.start
    end

    # Initialize a user-defined map of control change messages
    # @param [Array<Hash>] map
    # @return [Boolean]
    def initialize_midi_parameter_control(map)
      from_range = 0..127
      @midi.input.receive(:class => MIDIMessage::ControlChange) do |event|
        message = event[:message]
        if @midi.input.channel.nil? || @midi.input.channel == message.channel
          index = message.index
          mapping = map.find { |mapping| mapping[:index] == index }
          property = mapping[:property]
          to_range = SequenceParameters::RANGE[property]
          value = message.value
          value = Scale.transform(value).from(from_range).to(to_range)
          puts "MIDI: Arpeggiator #{property}= #{value}"
          @parameter.send("#{property}=", value)
        end
      end
    end

    # Emit any note off messages that are currently pending in the queue.  The clock triggers this 
    # when stopping or pausing
    # @return [Array<MIDIMessage::NoteOff>]
    def emit_pending_note_offs
      messages = @sequence.pending_note_offs
      @midi.output.puts(*messages)
      messages
    end

    # Initialize MIDI input and output
    # @param [Hash] devices
    # @param [Hash] options
    # @option options [Fixnum] :channel The receive channel (also: :rx_channel)
    # @option options [Array<Hash>] :midi_control Specify a user defined control change message map
    # @option options [Fixnum] :tx_channel The transmit channel
    # @return [Boolean]
    def initialize_midi_devices(devices, options = {})
      @midi = MIDIInstrument::Node.new
      @midi.input.devices.concat(devices[:input])
      @midi.input.channel = options[:rx_channel] || options[:channel]
      @midi.output.devices.concat(devices[:output])
      @midi.output.channel = options[:tx_channel]
      @midi
    end

    # Initialize adding and removing MIDI notes from the sequence
    def initialize_midi_note_control
      @midi.input.receive(:class => MIDIMessage::NoteOn) do |event|
        message = event[:message]
        if @midi.input.channel.nil? || @midi.input.channel == message.channel
          @sequence.add(message)
        end
      end   
      @midi.input.receive(:class => MIDIMessage::NoteOff) do |event| 
        message = event[:message]
        if @midi.input.channel.nil? || @midi.input.channel == message.channel
          @sequence.remove(message)
        end
      end
      true
    end

    # Initialize MIDI output, enabling the sequencer to emit notes
    # @return [Boolean]
    def initialize_midi_output
      @sequencer.event.perform << proc do |data| 
        @midi.output.puts(data) unless data.empty?
      end
      @sequencer.event.stop << proc { emit_pending_note_offs }
      true
    end

  end

end
