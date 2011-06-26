#!/usr/bin/env ruby
module Diamond
  
  class Arpeggiator
    
    extend Forwardable
    
    attr_reader :clock,
                :sequencer
    
    def_delegators :clock, 
                     :start, 
                     :stop, 
                     :sync_to, 
                     :<<
    def_delegators :sequencer, 
                     :add, 
                     :remove, 
                     :gate, 
                     :gate=, 
                     :interval, 
                     :interval=,
                     :pattern,
                     :pattern=,
                     :pointer,
                     :resolution, 
                     :rate, 
                     :rate=
                
    def initialize(tempo, options = {}, &block)
      resolution = options[:resolution] || 128
      quarter_note = resolution / 4
      
      initialize_midi_io(options[:midi]) unless options[:midi].nil?
      
      @sequencer = Sequencer.new(resolution, options)
      initialize_clock(tempo, resolution, options)
      bind_events(&block)
    end
    
    private
    
    def initialize_clock(tempo, resolution, options)
      sync_to = [options[:sync_to]].flatten.compact
      children = [options[:children]].flatten.compact
      @clock = Topaz::Tempo.new(tempo, :sync_to => sync_to, :children => children)
      dif = resolution / @clock.interval  
      @clock.interval = @clock.interval * dif
    end
    
    def initialize_midi_io(devices)
      devices = [devices].flatten
      @midi_destinations = devices.find_all { |d| d.type == :output }
      @midi_sources = devices.find_all { |d| d.type == :input }   
    end
    
    def bind_events(&block)
      @clock.on_tick do 
        @sequencer.with_next do |msgs|
          data = msgs.map { |msg| msg.to_bytes }.flatten
          @midi_destinations.each { |o| o.puts(data) } unless data.empty?
          yield(msgs) unless block.nil?
        end
      end 
    end
  
  end
  
end
