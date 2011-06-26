#!/usr/bin/env ruby
module Diamond
  
  # a NoteEvent is a pairing of a MIDI NoteOn and NoteOff message
  # has a length that corresponds to sequencer ticks
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
