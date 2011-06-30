#!/usr/bin/env ruby
module Diamond
  
  module MIDIEmitter
            
    def add_midi_destinations(destinations)
      destinations = [destinations].flatten.compact
      @midi_destinations += destinations
      after_midi_destinations_updated
    end
    
    def remove_midi_destinations(destinations)
      destinations = [destinations].flatten.compact
      @midi_destinations.delete_if { |d| destinations.include?(d) }
      after_midi_destinations_updated
    end
    
    def emit_midi(data)
      @midi_destinations.each { |o| o.puts(data) }
    end
    
    private
            
    def initialize_midi_emitter(output_devices)
      @midi_destinations ||= []
      add_midi_destinations(output_devices)
    end
          
  end
  
end
