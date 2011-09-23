#!/usr/bin/env ruby
module Diamond
  
  class ArpeggiatorSequence
    
    extend Forwardable
    
    attr_reader :gate,
                :interval,
                :pattern,
                :range,
                :rate,
                :pattern_offset,
                :resolution

    def_delegators :@sequence, :length
        
    def initialize(resolution, options = {})
      @resolution = resolution
      @transpose = 0
      @interval = options[:interval] || 12
      @range = constrain((options[:range] || 3), :min => 0)
      @pattern_offset = options[:pattern_offset] || 0
      @pattern = options[:pattern] || Pattern.all.first
      @input_note_messages = []
      @rate = constrain((options[:rate] || 8), :min => 0, :max => @resolution)
      @gate = constrain((options[:gate] || 75), :min => 1, :max => 500)
      
      # realtime
      @changed = false
      @queue = []
      
      update_sequence
    end
    
    # yields to <em>block</em>, passing in the next messages in the queue
    # also returns the next messages
    def step(pointer, &block)
      if @changed && (pointer % @rate == 0)
        update_sequence
        @changed = false
      end
      queue_next(pointer)
      messages = @queue.shift || []
      yield(messages) unless block.nil?
      messages
    end
    
    # add input note_messages
    # takes a single message or an array
    def add(note_messages)
      @input_note_messages += [note_messages].flatten
      mark_changed
      true
    end
    
    # remove input note messages with the same note value
    # takes a single message or an array
    def remove(note_messages) 
      @input_note_messages.delete_if do |msg|
        deletion_queue = [note_messages].flatten.map { |note_message| note_message.note }
        deletion_queue.include?(msg.note)
      end
      mark_changed
      true
    end
    
    # remove all input note messages
    def remove_all
      @input_note_messages.clear
      mark_changed
      true
    end
        
    # set the gate property
    def gate=(num)
      @gate = constrain(num, :min => 1, :max => 500)
      mark_changed
      @gate
    end

    # set the interval property
    def interval=(num)
      @interval = num
      mark_changed
      @interval
    end
    
    # set the pattern pattern_offset property
    def pattern_offset=(num)
      @pattern_offset = num
      mark_changed
      @pattern_offset
    end
    
    # set the range property
    def range=(num)
      @range = constrain(num, :min => 0)
      mark_changed
      @range
    end
    
    # set the rate property
    def rate=(num)
      @rate = constrain(num, :min => 0, :max => @resolution)
      mark_changed
      @rate
    end
    
    # set the pattern property
    def pattern=(pattern)
      @pattern = pattern
      mark_changed
      @pattern
    end
    
    # transpose everything by <em>num</em> scale degrees
    def transpose(num = nil)
      @transpose = num unless num.nil?
      mark_changed
      @transpose      
    end
    alias_method :transpose=, :transpose
    
    # returns an array containing all NoteOff messages in the queue
    def pending_note_offs
      @queue.map do |slot|
        slot.find { |m| m.class == MIDIMessage::NoteOff } unless slot.nil?
      end.flatten.compact
    end
        
    private
    
    def constrain(value, options = {})
      new_val = value
      new_val = [value, options[:min]].max unless options[:min].nil?
      new_val = [value, options[:max]].min unless options[:max].nil?
      new_val
    end
    
    def queue_next(pointer)
      events = @sequence[pointer]
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
        @pattern_offset.times { notes.push(notes.shift) }
        notes.each_with_index do |note_msg, i| 
          index = i * note_length
          @sequence[index] = [Inst::MIDINoteEvent.new(note_msg, @gate)] unless @sequence[index].nil?
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
          note = msg.note + degree + @transpose
          MIDIMessage::NoteOn.new(msg.channel, note, msg.velocity)
        end
      end
      notes.flatten.compact
    end                
  end
  
end
