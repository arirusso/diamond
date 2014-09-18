module Diamond

  module MIDI

    module Input

      def self.included(base)
        base.send(:extend, Forwardable)
        base.send(:def_delegators, :@midi,
                  :<<,
                  :input,
                  :inputs,
                  :omni_on,
                  :rx_channel, 
                  :receive_channel,
                  :rx_channel=,
                  :receive_channel=)
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

      # Initialize adding and removing MIDI notes from the sequence
      # @param [Sequence] sequence
      # @return [Boolean]
      def enable_note_control(sequence)
        @midi.input.receive(:class => MIDIMessage::NoteOn) do |event|
          message = event[:message]
          if @midi.input.channel.nil? || @midi.input.channel == message.channel
            sequence.add(message)
          end
        end   
        @midi.input.receive(:class => MIDIMessage::NoteOff) do |event| 
          message = event[:message]
          if @midi.input.channel.nil? || @midi.input.channel == message.channel
            sequence.remove(message)
          end
        end
        true
      end

      # Initialize a user-defined map of control change messages
      # @param [SequenceParameters] parameters
      # @param [Array<Hash>] map
      # @return [Boolean]
      def enable_parameter_control(parameters, map)
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
            parameters.send("#{property}=", value)
          end
        end
      end

      private

      # @param [Array<UniMIDI::Input>] inputs
      # @param [Hash] options
      # @option options [Fixnum] :channel The receive channel (also: :rx_channel)
      def initialize_input(inputs, options = {})
        @midi.input.devices.concat(inputs)
        @midi.input.channel = options[:rx_channel] || options[:channel]
      end

    end

    module Output

      def self.included(base)
        base.send(:extend, Forwardable)
        base.send(:def_delegators, :@midi,
                  :mute,
                  :mute=,
                  :output,
                  :outputs,
                  :toggle_mute,
                  :tx_channel, 
                  :transmit_channel,
                  :tx_channel=,
                  :transmit_channel=)
      end

      # Initialize MIDI output, enabling the sequencer to emit notes
      # @param [Sequencer::Core] sequencer
      # @return [Boolean]
      def enable_output(sequencer)
        sequencer.event.perform << proc do |data| 
          @midi.output.puts(data) unless data.empty?
        end
        sequencer.event.stop << proc { emit_pending_note_offs }
        true
      end

      private

      # Initialize MIDI output
      # @param [Array<UniMIDI::Output>] outputs
      # @param [Hash] options
      # @option options [Fixnum] :tx_channel The transmit channel
      def initialize_output(outputs, options = {})
        @midi.output.devices.concat(outputs)
        @midi.output.channel = options[:tx_channel]
      end

    end

    class Node

      include Input
      include Output

      # Initialize MIDI input and output
      # @param [Hash] devices
      # @param [Hash] options
      # @option options [Fixnum] :channel The receive channel (also: :rx_channel)
      # @option options [Fixnum] :tx_channel The transmit channel
      def initialize(devices, options = {})
        @midi = MIDIInstrument::Node.new
        initialize_input(devices[:input], options)
        initialize_output(devices[:output], options)
      end

    end

    def self.new(*args)
      Node.new(*args)
    end

  end
end
