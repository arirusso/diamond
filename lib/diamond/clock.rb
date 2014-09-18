module Diamond

  class Clock

    extend Forwardable

    def_delegators :@clock, :event, :pause, :unpause

    def initialize(*args)
      @arpeggiators = []
      @clock = Sequencer::Clock.new(*args)
    end

    def start(options = {})
      begin
        @clock.start(options)
      rescue SystemExit, Interrupt => exception
        stop
      end
    end

    def stop
      @arpeggiators.each { |arpeggiator| arpeggiator.sequencer.event.do_stop }
      @clock.stop
      true
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
