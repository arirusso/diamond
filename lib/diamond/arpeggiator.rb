module Diamond

  class Arpeggiator

    include API::MIDI
    include API::Sequence
    include OSCAccessible

    attr_reader :sequence, :sequencer

    DefaultChannel = 0
    DefaultVelocity = 100

    # @param [Hash] options
    # @option options [Fixnum] :rx_channel (or :channel) Only respond to input messages to the given MIDI channel. will operate on all input sources. if not included, or nil the arpeggiator will work in omni mode and respond to all messages
    # @option options [Fixnum] :gate Duration of the arpeggiated notes. The value is a percentage based on the rate.  If the rate is 4, then a gate of 100 is equal to a quarter note. the default <tt>gate</tt> is 75. <tt>Gate</tt> must be positive and less than 500
    # @option options [Fixnum] :interval Increment (pattern) over (interval) scale degrees (range) times.  May be positive or negative. (default: 12)
    # @option options [Array<UniMIDI::Input, UniMIDI::Output>, UniMIDI::Input, UniMIDI::Output] :midi MIDI devices to use
    # @option options [Boolean] :midi_clock_output Should this Arpeggiator output midi clock? (default: false)
    # @option options [Fixnum] :tx_channel Send output messages to the given MIDI channel despite what channel the input notes were intended for.
    # @option options [Fixnum] :pattern_offset Begin on the nth note of the sequence (but not omit any notes). (default: 0)
    # @option options [Pattern] :pattern Compute the contour of the arpeggiated melody
    # @option options [Fixnum] :range Increment the (pattern) over (interval) scale degrees (range) times. Must be positive (abs will be used). (default: 3)
    # @option options [Fixnum] :rate How fast the arpeggios will be played. Must be positive (abs will be used). (default: 8, eighth note.) rate may be 0 (whole note) or greater but must be equal to or less than <tt>resolution</tt>
    # @option options [Fixnum] :resolution Numeric resolution for rhythm (default: 128)   
    def initialize(options = {}, &block)
      devices = MIDIInstrument::Device.partition(options[:midi])
      resolution = options[:resolution] || 128

      initialize_midi(devices, options)
      initialize_sequencer(resolution, devices[:output], options)
      initialize_osc(options) if !!options[:osc_input_port]
    end

    # Add MIDI input notes 
    # @param [Array<MIDIMessage>, MIDIMessage, *MIDIMessage] args
    # @return [Array<MIDIMessage>]
    def add(*args)
      @midi.input << args
    end
    alias_method :<<, :add

    def remove(*args)
      @midi.add_messages(*args)
    end

    private

    def sanitize_input_notes(notes, klass, options)
      channel = options[:channel] || DefaultChannel
      velocity = options[:velocity] || DefaultVelocity
      notes = notes.map do |note|
        note.kind_of?(String) ? klass[note].new(channel, velocity) : note
      end.compact
      process_input(notes)
    end

    def initialize_midi(devices, options = {})
      @midi = MIDIInstrument::Node.new
      @midi.input.devices.concat(devices[:input])
      @midi.output.devices.concat(devices[:output])
      @midi.input.channel = options[:rx_channel] || options[:channel]
      @midi.output.channel = options[:tx_channel] 
      @midi.input.receive(:class => MIDIMessage::NoteOn) { |event| @sequence.add(event[:message]) }
      @midi.input.receive(:class => MIDIMessage::NoteOff) { |event| @sequence.remove(event[:message]) }
    end

    def initialize_sequencer(resolution, outputs, options = {})
      @sequence = ArpeggiatorSequence.new(resolution, options)
      @sequencer = Sequencer.new
      @sequencer.event.perform do |data| 
        @midi.output.puts(data) unless data.empty?
      end
    end

    def initialize_osc(options = {})
      osc_start(:input_port => options[:osc_input_port], :output => options[:osc_output], :map => options[:osc_map], :service_name => options[:name])
    end

  end

end
