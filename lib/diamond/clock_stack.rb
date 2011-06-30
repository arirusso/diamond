#!/usr/bin/env ruby
module Diamond
  
  # a ClockStack allows the user to sync arpeggiators to various clocks during their lifespan
  # it handles all of the work of moving MIDI destinations between clocks as well as sending
  # stop and start messages to the right clocks at the right time
  class ClockStack
    
    extend Forwardable
    
    attr_reader :clocks
    
    def_delegators :clock, :join
    
    def initialize(tempo_or_input, resolution, options = {})
      @clocks = []
      @actions = {
        :tick => {}
      }
            
      initialize_native_clock(tempo_or_input, resolution)
            
      bind_actions
    end
    
    def ensure_tick_action(arp, &block)
      @actions[:tick][arp] = block
    end
    
    def remove_tick_action(arp)
      @actions[:tick][arp].delete
    end
    
    # the clock that is currently being used
    def clock
      @clocks.last
    end
    
    def add(clock)
      @clocks << clock
    end
    alias_method :<<, :add
            
    def remove(clock)
      @clocks.delete(clock)
    end
    
    # the clock that this Arpeggiator was born with
    def native_clock
      @clocks.first
    end
    
    # start the clock
    # only the native clock can be started
    def start(*a)
      native_clock.start(*a)
    end
    
    # stops the clock and sends any remaining MIDI note-off messages that are in the queue
    # only the native clock can be stopped
    def stop
      native_clock.stop             
    end
    
    def update_destinations(destinations)
      clock.destinations.clear
      last_clock.destinations.clear unless last_clock.nil?
      clock.add_destination(destinations) 
    end
        
    private
    
    def last_clock
      @clocks[@clocks.length-2]
    end
        
    def initialize_native_clock(tempo_or_input, resolution)
      @clocks << Topaz::Tempo.new(tempo_or_input, :midi => @midi_destinations)
      dif = resolution / clock.interval  
      clock.interval = clock.interval * dif
    end
    
    def bind_actions
      clock.on_tick do
        @actions[:tick].values.each { |a| a.call }
      end
    end
      
  end
  
end
