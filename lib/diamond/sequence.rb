module Diamond

  class Sequence

    extend Forwardable

    def_delegators :@sequence, :each, :first, :last, :length

    def initialize 
      @parameter = nil
      # realtime
      @changed = false
      @input_queue = []
      @queue = []
    end

    # The bucket of messages for the given pointer
    # @param [Fixnum] pointer
    # @return [Array<MIDIMessage>]
    def at(pointer)
      if changed? && (pointer % @parameter.rate == 0)
        update
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

    # Mark the sequence as changed
    # @return [Boolean]
    def mark_changed
      @changed = true
    end

    protected

    # Apply the given parameters object
    # @param [SequenceParameters] parameters
    # @return [SequenceParameters]
    def use_parameters(parameters)
      @parameter = parameters
      update
    end

    private

    # Enqueue next bucket for the given pointer
    # @param [Fixnum] pointer
    # @return [Array<NoteEvent>]
    def enqueue_next(pointer)
      bucket = @sequence[pointer]
      enqueue(bucket) unless bucket.nil?
      bucket
    end

    # Prepare the given event bucket for performance, moving note messages to the queue
    # @param [Array<NoteEvent>] bucket
    # @return [Array<NoteEvent>]
    def enqueue(bucket)
      bucket.map do |event|
        @queue[0] ||= []
        @queue[0] << event.start 
        float_length = (event.length.to_f / 100) * @parameter.duration.to_f
        length = float_length.to_i
        @queue[length] ||= []
        @queue[length] << event.finish
        event
      end
    end

    # Commit changes to the sequence
    # @return [ArpeggiatorSequence]
    def update
      notes = get_note_sequence
      initialize_sequence(notes.length)
      populate_sequence(notes) unless notes.empty?
      @sequence
    end

    # (Re)initialize the sequence with the given length
    # @param [Fixnum] length
    # @return [Array]
    def initialize_sequence(length)
      sequence_length_in_ticks = length * @parameter.duration
      @sequence = Array.new(sequence_length_in_ticks, [])
    end

    # Populate the sequence with the given notes
    # @param [Array<MIDIMessage::NoteOn>] notes
    # @return [Array<Array<NoteEvent>>]
    def populate_sequence(notes)
      @parameter.pattern_offset.times { notes.push(notes.shift) }
      notes.each_with_index do |note, i| 
        index = i * @parameter.duration
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
      event = MIDIInstrument::NoteEvent.new(note_message, @parameter.gate)
      [event]
    end

    # The input queue as note messages
    # @return [Array<MIDIMessage::NoteOn>]
    def get_note_sequence
      notes = @parameter.computed_pattern.map do |degree|
        @input_queue.map do |message| 
          note = message.note + degree + @parameter.transpose
          MIDIMessage::NoteOn.new(message.channel, note, message.velocity)
        end
      end
      notes.flatten.compact
    end 

  end

end
