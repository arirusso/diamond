#!/usr/bin/env ruby
module Diamond
  
  module MIDIEmitter
    
    def self.included(base)
      base.send(:attr_reader, :midi_destinations)
    end
    
    # stop and send note-offs to all destinations for all notes and channels
    def quiet!
      stop
      @midi_destinations.each do |output|
        (0..127).each do |note| 
          (0..15).each do |channel|
            msg = MIDIMessage::NoteOff(channel, note, 0) 
            output.puts(msg.to_bytes)
          end
        end
      end
    end
    
    # add an output where MIDI data will be sent
    def add_midi_destinations(destinations)
      destinations = [destinations].flatten.compact
      @midi_destinations += destinations
      on_midi_destinations_updated if respond_to?(:on_midi_destinations_updated)
    end
    
    # remove a destination
    def remove_midi_destinations(destinations)
      destinations = [destinations].flatten.compact
      @midi_destinations.delete_if { |d| destinations.include?(d) }
      on_midi_destinations_updated if respond_to?(:on_midi_destinations_updated)
    end
    
    # send MIDI data
    def emit_midi(data)
      @midi_destinations.each { |o| o.puts(data) }
    end
    
    # send all of the note off messages in the queue
    def emit_pending_note_offs
      data = @sequence.pending_note_offs.map { |msg| msg.to_bytes }.flatten.compact
      @midi_destinations.each { |o| o.puts(data) } unless data.empty?
    end
    
    private
    
    def emit_midi?
      !@midi_destinations.nil? && !@midi_destinations.empty?
    end
            
    def emit_midi_to(output_devices)
      @midi_destinations ||= []
      add_midi_destinations(output_devices)
    end
          
  end
  
end
