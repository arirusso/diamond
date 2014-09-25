module Diamond

  # A wrapper for Topaz::Tempo that's geared towards the arpeggiator
  class Clock

    extend Forwardable

    def_delegators :@clock, :midi_output, :event, :pause, :running?, :tempo, :tempo=, :unpause

    # @param [Fixnum, UniMIDI::Input] tempo_or_input
    # @param [Hash] options
    # @option options [Array<UniMIDI::Output>, UniMIDI::Output] :output MIDI output device(s) (also: :outputs)
    def initialize(tempo_or_input, options = {})
      @arpeggiators = []
      output = options[:output] || options[:outputs] || options[:midi]
      initialize_clock(tempo_or_input, :output => output)
      initialize_events
    end

    # Shortcut to the clock's MIDI output devices
    # @return [Array<UniMIDI::Output>]
    def midi_outputs
      @clock.midi_output.devices
    end

    # Start the clock
    # @param [Hash] options
    # @option options [Boolean] :blocking Whether to run in the foreground (also :focus, :foreground)
    # @option options [Boolean] :suppress_clock Whether this clock is a sync-slave
    # @return [Boolean]
    def start(options = {})
      begin
        @clock.start(options)
      rescue SystemExit, Interrupt => exception
        stop
      end
    end

    # Stop the clock (and fire the arpeggiator sequencer stop event)
    # @return [Boolean]
    def stop
      @arpeggiators.each { |arpeggiator| arpeggiator.sequencer.event.do_stop }
      @clock.stop
      true
    end

    # Add arpeggiator(s) to this clock's control
    # @param [Array<Arpeggiator>, Arpeggiator] arpeggiator
    # @return [Array<Arpeggiator>]
    def add(arpeggiator)
      arpeggiators = [arpeggiator].flatten
      @arpeggiators += arpeggiators
      @arpeggiators
    end
    alias_method :<<, :add

    # Remove arpeggiator(s) from this clock's control
    # @param [Array<Arpeggiator>, Arpeggiator] arpeggiator
    # @return [Array<Arpeggiator>]
    def remove(arpeggiator)
      arpeggiators = [arpeggiator].flatten
      @arpeggiators.delete_if? { |arpeggiator| arpeggiators.include?(arpeggiator) }
      @arpeggiators
    end

    private

    # @param [Fixnum, UniMIDI::Input] tempo_or_input
    # @param [Hash] options
    # @option options [Array<UniMIDI::Output>, UniMIDI::Output] :output MIDI output device(s)
    # @option options [Fixnum] :resolution
    # @return [Topaz::Clock]
    def initialize_clock(tempo_or_input, options = {})
      @clock = Topaz::Clock.new(tempo_or_input, :midi => options[:output])
      resolution = options.fetch(:resolution, 128)
      @clock.interval = @clock.interval * (resolution / @clock.interval)
      @clock
    end

    # Initialize the tick event
    # @return [Boolean]
    def initialize_events
      @clock.event.tick << proc do
        @arpeggiators.each do |arpeggiator|
          arpeggiator.sequencer.exec(arpeggiator.sequence)
          arpeggiator.sequencer.event.stop { @clock.stop }
          arpeggiator
        end
      end
      true
    end

  end

end
