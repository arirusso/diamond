module Diamond
  
  class ArpeggiatorSequence
    
    extend Forwardable
    
    attr_reader :gate,
                :input_queue,
                :interval,
                :pattern,
                :range,
                :rate,
                :pattern_offset,
                :resolution

    def_delegators :@sequence, :each, :first, :last, :length
        
    # @param [Fixnum] resolution
    # @param [Hash] options
    # @option options [Fixnum] :gate Duration of the arpeggiated notes. The value is a percentage based on the rate.  If the rate is 4, then a gate of 100 is equal to a quarter note. (default: 75). must be 1..500
    # @option options [Fixnum] :interval Increment (pattern) over (interval) scale degrees (range) times.  May be positive or negative. (default: 12)
    # @option options [Fixnum] :pattern_offset Begin on the nth note of the sequence (but not omit any notes). (default: 0)
    # @option options [Pattern] :pattern Compute the contour of the arpeggiated melody
    # @option options [Fixnum] :range Increment the (pattern) over (interval) scale degrees (range) times. Must be positive (abs will be used). (default: 3)
    # @option options [Fixnum] :rate How fast the arpeggios will be played. Must be positive (abs will be used). (default: 8, eighth note.) must be 0..resolution
    def initialize(resolution, options = {})
      @resolution = resolution
      @transpose = 0
      # realtime
      @changed = false
      @input_queue = []
      @queue = []

      apply_options(options) 
      update_sequence
    end
    
    # The bucket of messages for the given pointer
    # @param [Fixnum] pointer
    # @return [Array<MIDIMessage>]
    def at(pointer)
      if changed? && (pointer % @rate == 0)
        update_sequence
        @changed = false
      end
      enqueue_next(pointer)
      messages = @queue.shift || []
      messages
    end

    # Has the sequence changed since the last update?
    # @return [Boolean]
    def changed?
      @changed
    end
    
    # Add inputted note_messages
    # @param [Array<MIDIMessage::NoteOn>, MIDIMessage::NoteOn, *MIDIMessage::NoteOn] note_messages
    # @return [Boolean]
    def add(*note_messages)
      messages = [note_messages].flatten.compact
      @input_queue.concat(messages)
      mark_changed
      true
    end
    
    # Remove input note messages with the same note value
    # @param [Array<MIDIMessage::NoteOn, MIDIMessage::NoteOff>, MIDIMessage::NoteOff, MIDIMessage::NoteOn, *MIDIMessage::NoteOff, *MIDIMessage::NoteOn] note_messages
    # @return [Boolean]
    def remove(*note_messages) 
      messages = [note_messages].flatten
      deletion_queue = messages.map(&:note)
      @input_queue.delete_if { |message| deletion_queue.include?(message.note) }
      mark_changed
      true
    end
    
    # Remove all input note messages
    # @return [Boolean]
    def remove_all
      @input_queue.clear
      mark_changed
      true
    end
        
    # Set the gate property
    # @param [Fixnum] num
    # @return [Fixnum]
    def gate=(num)
      @gate = constrain(num, :min => 1, :max => 500)
      mark_changed
      @gate
    end

    # Set the interval property
    # @param [Fixnum] num
    # @param [Fixnum]
    def interval=(num)
      @interval = num
      mark_changed
      @interval
    end
    
    # Set the pattern offset property
    # @param [Fixnum] num
    # @return [Fixnum]
    def pattern_offset=(num)
      @pattern_offset = num
      mark_changed
      @pattern_offset
    end
    
    # Set the range property
    # @param [Fixnum] range
    # @return [Fixnum]
    def range=(num)
      @range = constrain(num, :min => 0)
      mark_changed
      @range
    end
    
    # Set the rate property
    # @param [Fixnum] num
    # @return [Fixnum]
    def rate=(num)
      @rate = constrain(num, :min => 0, :max => @resolution)
      mark_changed
      @rate
    end
    
    # Set the pattern property
    # @param [Pattern] pattern
    # @return [Pattern]
    def pattern=(pattern)
      @pattern = pattern
      mark_changed
      @pattern
    end
    
    # Transpose everything by the given number of scale degrees. Can be used as a getter
    # @param [Fixnum, nil] num
    # @return [Fixnum, nil]
    def transpose(num = nil)
      @transpose = num unless num.nil?
      mark_changed
      @transpose      
    end
    alias_method :transpose=, :transpose
    
    # All NoteOff messages in the queue
    # @return [Array<MIDIMessage::NoteOff>]
    def pending_note_offs
      messages = @queue.map do |bucket|
        unless bucket.nil?
          bucket.select { |m| m.class == MIDIMessage::NoteOff }       
        end
      end
      messages.flatten.compact
    end
        
    private

    # @param [Hash] options
    # @return [ArpeggiatorSequence]
    def apply_options(options)
      @interval = options[:interval] || 12
      @range = constrain((options[:range] || 3), :min => 0)
      @pattern_offset = options[:pattern_offset] || 0
      @pattern = options[:pattern] || Pattern.all.first
      @rate = constrain((options[:rate] || 8), :range => 0..@resolution)
      @gate = constrain((options[:gate] || 75), :range => 1..500)
      self
    end
    
    # Constrain the given value based on the sequence options
    # @param [Numeric] value
    # @param [Hash] options
    # @option options [Numeric] :min
    # @option options [Numeric] :max
    # @option options [Range] :range
    # @return [Numeric]
    def constrain(value, options = {})
      min = options[:range].nil? ? options[:min] : options[:range].begin
      max = options[:range].nil? ? options[:max] : options[:range].end
      new_value = [value, min].max unless min.nil?
      new_value = [value, max].min unless max.nil?
      new_value || value
    end
    
    # Enqueue next bucket for the given pointer
    # @param [Fixnum] pointer
    # @return [Array<NoteEvent>]
    def enqueue_next(pointer)
      bucket = @sequence[pointer]
      enqueue(bucket) unless bucket.nil?
      bucket
    end
    
    # The note duration given the sequence options
    # @return [Numeric]
    def duration
      @resolution / @rate
    end
        
    # Prepare the given event bucket for performance, moving note messages to the queue
    # @param [Array<NoteEvent>] bucket
    # @return [Array<NoteEvent>]
    def enqueue(bucket)
      bucket.map do |event|
        @queue[0] ||= []
        @queue[0] << event.start 
        float_length = (event.length.to_f / 100) * duration.to_f
        length = float_length.to_i
        @queue[length] ||= []
        @queue[length] << event.finish
        event
      end
    end
    
    # Mark the sequence as changed
    # @return [Boolean]
    def mark_changed
      @changed = true
    end
    
    # Commit changes to the sequence
    # @return [ArpeggiatorSequence]
    def update_sequence
      notes = get_note_sequence
      initialize_sequence(notes.length)
      populate_sequence(notes) unless notes.empty?
      @sequence
    end

    # (Re)initialize the sequence with the given length
    # @param [Fixnum] length
    # @return [Array]
    def initialize_sequence(length)
      sequence_length_in_ticks = length * duration
      @sequence = Array.new(sequence_length_in_ticks, [])
    end

    # Populate the sequence with the given notes
    # @param [Array<MIDIMessage::NoteOn>] notes
    # @return [Array<Array<NoteEvent>>]
    def populate_sequence(notes)
      @pattern_offset.times { notes.push(notes.shift) }
      notes.each_with_index do |note, i| 
        index = i * duration
        populate_bucket(index, note) unless @sequence[index].nil?
      end
      @sequence
    end

    # Populate the bucket for index with the given note message
    # @param [Fixnum] index
    # @param [MIDIMessage::NoteOn] note_message
    # @return [Array<NoteEvent>]
    def populate_bucket(index, note_message)
      @sequence[index] = create_bucket(note_message)
    end

    # Create a bucket/note event for the given note message
    # @param [MIDIMessage::NoteOn] note_message
    # @return [Array<NoteEvent>]
    def create_bucket(note_message)
      event = MIDIInstrument::NoteEvent.new(note_message, @gate)
      [event]
    end
    
    # The computed pattern given the sequence options
    # @return [Array<Fixnum>]
    def computed_pattern
      @pattern.compute(@range, @interval)
    end
    
    # The input queue as note messages
    # @return [Array<MIDIMessage::NoteOn>]
    def get_note_sequence
      notes = computed_pattern.map do |degree|
        @input_queue.map do |msg| 
          note = msg.note + degree + @transpose
          MIDIMessage::NoteOn.new(msg.channel, note, msg.velocity)
        end
      end
      notes.flatten.compact
    end                
  end
  
end
