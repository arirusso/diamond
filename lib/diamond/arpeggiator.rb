#!/usr/bin/env ruby
module Diamond
  
  class Arpeggiator
    
    attr_reader :gate,
                :interval,
                :pattern,
                :range,
                :pointer
    
    def initialize(options = {})
      @interval = options[:interval] || 12
      @range = options[:range] || 3
      #@pattern = options[:pattern] || Pattern.from_yaml(filename).first
      @input_note_messages = []
      @pattern = []
      
      @changed = false
      @offs = []
      @pointer = 0
      
      update_sequence
    end
    
    def step
      @offs = ons.map { |msg| msg.to_note_off }
      update_sequence if @changed
      @pointer = (@pointer >= (@sequence.length - 1)) ? 0 : @pointer + 1
    end
    
    def add(note_messages)
      @input_note_messages += [note_messages].flatten
      mark_changed
    end
    
    def remove(note_messages)
      @input_note_messages.delete_if do |msg|
        deletion_queue = [note_messages].flatten.map { |note_message| note_message.note }
        deletion_queue.include?(msg.note)
      end
      mark_changed
    end
    
    def ons
      [@sequence[@pointer]].flatten.compact
    end
    
    def messages
      ons + @offs
    end
    
    def messages_as_bytes
      messages.map { |msg| msg.to_bytes }.flatten.compact
    end
    
    def gate=(num)
      @gate = num
      mark_changed
    end

    def interval=(num)
      @interval = num
      mark_changed
    end
    
    def range=(num)
      @range = num
      mark_changed
    end
        
    private
    
    def mark_changed
      @changed = true
    end
    
    def update_sequence
      @sequence = []
      @range.times do |r|
        @sequence += @input_note_messages.map do |msg|
          note = msg.note + (12*(r+1))
          MIDIMessage::NoteOn.new(msg.channel, note, msg.velocity)
        end
      end
    end
      
  end
  
end
