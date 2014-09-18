module Diamond

  # A wrapper for Sequencer::Clock (and thus Topaz::Tempo) that's geared towards the arpeggiator
  class Clock

    extend Forwardable

    def_delegators :@clock, :event, :pause, :unpause

    # @param [Fixnum, UniMIDI::Input] tempo_or_input
    # @param [Hash] options
    # @option options [Array<UniMIDI::Output>, UniMIDI::Output] :outputs MIDI output device(s)
    def initialize(*args)
      @arpeggiators = []
      @clock = Sequencer::Clock.new(*args)
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

    # Add an arpeggiator to this clock's control
    # @param [Array<Arpeggiator>, Arpeggiator] arpeggiator
    # @return [Boolean]
    def add(arpeggiator)
      arpeggiators = [arpeggiator].flatten
      result = arpeggiators.map do |arpeggiator|
        unless @arpeggiators.include?(arpeggiator)
          @arpeggiators << arpeggiator
          reset_tick
          true
        else
          false
        end
      end
      result.any?
    end
    alias_method :<<, :add

    # Remove an arpeggiator from this clock's control
    # @param [Arpeggiator] arpeggiator
    # @return [Boolean]
    def remove(arpeggiator)
      arpeggiators = [arpeggiator].flatten
      result = arpeggiators.map do |arpeggiator|
        if @arpeggiators.include?(arpeggiator)
          @arpeggiators.delete(arpeggiator)
          reset_tick
          true
        else
          false
        end
      end
      result.any?
    end

    private

    # Reset the clock's tick event (used when arpeggiators are added or removed)
    # @return [Array<Arpeggiator>] Arpeggiators that are now actively controlled by this clock
    def reset_tick
      @clock.event.tick.clear
      @arpeggiators.map do |arpeggiator|
        @clock.event.tick << proc { arpeggiator.sequencer.exec(arpeggiator.sequence) }
        arpeggiator.sequencer.event.stop { @clock.stop }
        arpeggiator
      end
    end
  end

end
