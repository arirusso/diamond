module Diamond

  class Clock

    extend Forwardable

    def_delegators :@clock, :event, :pause, :start, :stop, :unpause

    def initialize(*args)
      @arpeggiators = []
      @clock = Sequencer::Clock.new(*args)
    end

    def add(arpeggiator)
      unless @arpeggiators.include?(arpeggiator)
        @arpeggiators << arpeggiator
        reset_tick
      end
    end
    alias_method :<<, :add

    def remove(arpeggiator)
      if @arpeggiators.include?(arpeggiator)
        @arpeggiators.delete(arpeggiator)
        reset_tick
      end
    end

    private

    def reset_tick
      @clock.event.tick.clear
      @arpeggiators.each do |arpeggiator|
        @clock.event.tick << proc { arpeggiator.sequencer.exec(arpeggiator.sequence) }
        arpeggiator.sequencer.event.stop { @clock.stop }
      end
    end
  end

end
