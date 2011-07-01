#!/usr/bin/env ruby
module Diamond
  
  class Arpeggiator
    
    include MIDIEmitter
    include MIDIReceiver
    include Syncable
    
    extend Forwardable
    
    DefaultChannel = 0
    DefaultVelocity = 100
    
    attr_reader :clock,
                :sequence
                
    attr_accessor :channel
    
    def_delegators :clock, :join, :start, :stop
                         
    #
    # a numeric tempo rate (BPM), or unimidi input is required by the constructor.  in the case that you use a MIDI input, it will be used as a clock source
    #
    # the constructor also accepts a number of options
    #       
    # * channel - restrict input messages to the given MIDI channel. will operate on all input sources
    #
    # * gate - <tt>gate</tt> refers to how long the arpeggiated notes will be held out. the <tt>gate</tt> value is a percentage based on the rate.  if the rate is 4, then a gate of 100 is equal to a quarter note. the default <tt>gate</tt> is 75. <tt>Gate</tt> must be positive and less than 500
    #
    # * interval - the arpeggiator increments the <tt>pattern</tt> over <tt>interval</tt> scale degrees <tt>range</tt> times.  the default <tt>interval</tt> is 12, meaning one octave above the current note. <tt>interval</tt> may be any positive or negative number
    #  
    # * midi - this can be a unimidi input or output. will accept a single device or an array
    #
    # * midi_clock_output - should this Arpeggiator output midi clock? defaults to false
    #
    # * pattern_offset - <tt>pattern_offset</tt> n means that the arpeggiator will begin on the nth note of the sequence (but not omit any notes). the default <tt>pattern_offset</tt> is 0.
    # 
    # * pattern - A Pattern object that computes the contour of the arpeggiated melody
    #    
    # * range - the arpeggiator increments the <tt>pattern</tt> over <tt>interval</tt> scale degrees <tt>range</tt> times. <tt>range</tt> must be 0 or greater. the default <tt>range</tt> is 3
    #
    # * rate - <tt>rate</tt> is how fast the arpeggios will be played. the default is 8, which is an eighth note. rate may be 0 (whole note) or greater but must be equal to or less than <tt>resolution</tt>
    #  
    # * resolution - the resolution of the arpeggiator (numeric notation)    
    #    
    def initialize(tempo_or_input, options = {}, &block)
      @mute = false      
      @actions = { :tick => nil }
      
      @channel = options[:channel]
      
      midi_devices = options[:midi]      
      midi_clock_output = options[:midi_clock_output] || false
      resolution = options[:resolution] || 128      

      initialize_midi_io(midi_devices) unless midi_devices.nil?            
      initialize_syncable(options[:sync_to], options[:sync])      
      initialize_clock(tempo_or_input, resolution, midi_clock_output)
      
      @sequence = ArpeggiatorSequence.new(resolution, options)

      bind_events(&block)
    end
    
    def method_missing(method, *args, &block)
      @sequence.respond_to?(method) ? @sequence.send(method, *args, &block) : super
    end
    
    # add input notes. takes a single note or an array of notes
    def add(notes, options = {})
      notes = [notes].flatten
      notes = sanitize_input_notes(notes, MIDIMessage::NoteOn, options)
      @sequence.add(notes)
      self
    end
    
    # remove input notes. takes a single note or an array of notes
    def remove(notes, options = {})
      notes = [notes].flatten
      notes = sanitize_input_notes(notes, MIDIMessage::NoteOff, options)
      @sequence.remove(notes)
      self
    end
    
    # toggle mute on this arpeggiator
    def toggle_mute
      muted? ? unmute : mute
    end
    
    # mute this arpeggiator
    def mute
      @mute = true
      emit_pending_note_offs
      @mute
    end
    
    # unmute this arpeggiator
    def unmute
      @mute = false
    end
    
    # is this arpeggiator muted?
    def muted?
      @mute
    end
    
    # stops the clock and sends any remaining MIDI note-off messages that are in the queue
    def stop
      @clock.stop
      emit_pending_note_offs
      self             
    end
    
    private
    
    def sanitize_input_notes(notes, klass, options)
      channel = options[:channel] || DefaultChannel
      velocity = options[:velocity] || DefaultVelocity
      notes.map do |note|
        note = note.kind_of?(String) ? klass[note].new(channel, velocity) : note
        (@channel.nil? || note.channel == @channel) ? note : nil 
      end.compact
    end
    
    def update_clock
      @midi_destinations.each do |dest|
        @clock.remove_destination(dest)
        @clock.add_destination(dest)
      end
      #@clock.update_midi_clock_destinations(@midi_destinations)
    end
    alias_method :on_midi_destinations_updated, :update_clock
    alias_method :on_sync_updated, :update_clock
    
    def initialize_clock(tempo_or_input, resolution, use_midi_clock_output)
      outputs = use_midi_clock_output ? @midi_destinations : nil
      @clock = Topaz::Tempo.new(tempo_or_input, :midi => outputs)
      dif = resolution / clock.interval  
      clock.interval = clock.interval * dif
      clock.on_tick do
        @actions[:tick].call
        @sync_set.each { |syncable| syncable.sync_tick } 
      end
    end
            
    def initialize_midi_io(devices)
      devices = [devices].flatten
      emit_midi_to(devices.find_all { |d| d.type == :output }.compact)
      receive_midi_from(devices.find_all { |d| d.type == :input }.compact)      
    end
    
    def initialize_midi_source_listener(source)
      listener = MIDIEye::Listener.new(source)
      listener.listen_for(:class => MIDIMessage::NoteOn) { |event| add(event[:message]) }
      listener.listen_for(:class => MIDIMessage::NoteOff) { |event| remove(event[:message]) }
      listener.start(:background => true)
      listener
    end
    
    def bind_events(&block)
      @actions[:tick] = Proc.new do
        @sequence.with_next do |msgs|
          unless muted?
            data = msgs.map { |msg| msg.to_bytes }.flatten
            unless data.empty?
              emit_midi(data) if emit_midi?
              activate_sync_queue
            end
            yield(msgs) unless block.nil?
          end
        end
      end
      #update_clock       
    end
  
  end
  
end
