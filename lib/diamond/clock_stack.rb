#!/usr/bin/env ruby
module Diamond
  
  # a ClockStack allows the user to sync arpeggiators to various clocks during their lifespan
  # it handles all of the work of moving MIDI destinations between clocks as well as sending
  # stop and start messages to the right clocks at the right time
  class ClockStack
    
    extend Forwardable
    
    attr_reader :clocks
    
    def_delegators :clock, :join
    
    def initialize(tempo_or_input, options = {})
      @clocks = []
      @actions = {
        :tick => {}
      }
      
      resolution = options[:resolution] || 128
      quarter_note = resolution / 4
      
      initialize_native_clock(tempo_or_input, resolution, options)
      
      bind_actions
    end
    
    def add_tick_action(arp, &block)
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
      clock.add_destination(destinations)
      last_clock.remove_destination(destinations) unless last_clock.nil?
    end
        
    private
    
    def last_clock
      @clocks[@clocks.length-2]
    end
        
    def initialize_native_clock(tempo_or_input, resolution, options)
      sync_to = [options[:sync_to]].flatten.compact
      children = [options[:children]].flatten.compact
      child_clocks = children.map { |arp| arp.clock }
      @clocks << Topaz::Tempo.new(tempo_or_input, :sync_to => sync_to, :children => child_clocks, :midi => @midi_destinations)
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