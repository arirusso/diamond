#!/usr/bin/env ruby
module Diamond
  
  class Arpeggiator
    
    extend Forwardable
    
    attr_reader :clock,
                :sequencer
    
    def_delegators :clock, :start, :stop
    def_delegators :sequencer, :add, :remove
                
    def initialize(tempo, options = {}, &block)
      resolution = options[:resolution] || 128
      quarter_note = resolution / 4
      
      @sequencer = Sequencer.new(resolution, options)
      @clock = Topaz::Tempo.new(tempo)
      dif = resolution / @clock.interval  
      @clock.interval = @clock.interval * dif
      @clock.on_tick { @sequencer.with_next { |msgs| yield(msgs) } }  
    end
          
  end
  
end
