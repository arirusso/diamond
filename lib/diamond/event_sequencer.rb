#!/usr/bin/env ruby
module Diamond

  module EventSequencer

    # if it evaluates to true, no messages will be outputted during that
    # step. (however, the tick event will still be fired)
    # Arpeggiator#sequence is passed to the block
    def rest_when(&block)
      @events[:rest_when] = block
    end
    
    # should the arpeggiator rest on the current step?
    def rest?
      @events[:rest_when].nil? ? false : @events[:rest_when].call(@sequence) 
    end

    # if it evaluates to true, the sequence will go back to step 0
    # Arpeggiator#sequence is passed to the block  
    def reset_when(&block)
      @events[:reset_when] = block
    end
    
    # should the arpeggiator reset on the current step?
    def reset?
      @events[:reset_when].nil? ? false : @events[:reset_when].call(@sequence) 
    end
    
    private
    
    def initialize_event_sequencer
      @events ||= {}
    end
        
  end
  
end
