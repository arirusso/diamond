#!/usr/bin/env ruby
module Diamond
  
  class NoteEvent
    
    extend Forwardable
    
    attr_reader :start,
                :finish,
                :length
    
    def_delegators :start, :note
                
    def initialize(note_on_message, length)
      @start = note_on_message
      @length = length
      
      @finish = note_on_message.to_note_off
      
    end
          
  end
  
end
