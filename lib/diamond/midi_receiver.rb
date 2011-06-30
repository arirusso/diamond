#!/usr/bin/env ruby
module Diamond
  
  module MIDIReceiver
    
    def self.included(base)
      base.send(:attr_reader, :midi_sources)
    end
    
    # add a midi input to use as a source for arpeggiator notes
    def add_midi_source(source)      
      listener = initialize_midi_source_listener(source)
      @midi_sources ||= {}
      @midi_sources[source] = listener
    end
    
    # remove a midi input that was being used as a source for arpeggiator notes
    def remove_midi_source(source)
      @midi_sources[source].stop
      @midi_sources.delete(source)
    end
            
    private
    
    def receive_midi_from(input_devices)
      input_devices.each { |source| add_midi_source(source) }
    end
          
  end
  
end
