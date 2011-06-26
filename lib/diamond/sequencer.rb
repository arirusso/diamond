#!/usr/bin/env ruby
module Diamond
  
  class Sequencer
    
    attr_reader :gate,
                :interval,
                :pattern,
                :range,
                :rate,
                :pointer,
                :resolution
    
    def initialize(resolution, options = {})
      @resolution = resolution
      @interval = options[:interval] || 12
      @range = options[:range] || 3
      @pattern = options[:pattern] || Pattern.all.first
      @input_note_messages = []
      @rate = options[:rate] || 4
      @gate = options[:gate] || 75
      
      # realtime
      @changed = false
      @pointer = -1
      @queue = []
      
      update_sequence
    end
    
    def with_next(&block)
      if @changed && (@pointer % @rate == 0)
        update_sequence
        @changed = false
      end
      queue_next
      messages = @queue.shift || []
      yield(messages)
      messages
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
    
    def rate=(num)
      @rate = num
      mark_changed
    end
    
    def pattern=(pattern)
      @pattern = pattern
      mark_changed
    end
        
    private
    
    def queue_next
      @pointer = (@pointer >= (@sequence.length - 1)) ? 0 : @pointer + 1
      events = @sequence[@pointer]
      add_to_queue(events) unless events.nil?
    end
    
    def note_length
      @resolution / @rate
    end
    
    def add_to_queue(events)
      events.each do |event|
        @queue[0] ||= []
        @queue[0] << event.start
        length = ((event.length.to_f / 100) * note_length.to_f).to_i
        @queue[length] ||= []
        @queue[length] << event.finish
      end
    end
    
    def mark_changed
      @changed = true
    end
    
    def update_sequence
      notes = get_note_sequence
      sequence_length_in_ticks = notes.length * note_length
      @sequence = Array.new(sequence_length_in_ticks, [])
      unless notes.empty?
        notes.each_with_index do |note_msg, i|
          index = i * note_length
          @sequence[index] = [NoteEvent.new(note_msg, @gate)] unless @sequence[index].nil?
        end
      end
      @sequence
    end
    
    def computed_pattern
      @pattern.compute(@range, @interval)
    end
    
    def get_note_sequence
      notes = []
      computed_pattern.each do |degree|
        notes += @input_note_messages.map do |msg| 
          note = msg.note + degree
          MIDIMessage::NoteOn.new(msg.channel, note, msg.velocity)
        end
      end
      notes.flatten.compact
    end                
  end
  
end
