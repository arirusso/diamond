#!/usr/bin/env ruby
module Diamond

  module EventSequencer

    # will be called on each step-- if it evaluates to true, no messages will be outputted during that
    # step. (however, the tick event will still be fired)
    # Arpeggiator#sequence is passed to the block
    def rest_when(&block)
      @events[:rest_when] = block
    end
    
    # should the arpeggiator rest on the current step?
    def rest?
      @events[:rest_when].call(@sequence) unless @events[:rest_when].nil?
    end
    
    private
    
    def initialize_event_sequencer
      @events ||= {}
    end
        
  end
  
end
