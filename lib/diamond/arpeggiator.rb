#!/usr/bin/env ruby
module Diamond
  
  class Arpeggiator
    
    include MIDIEmitter
    include MIDIReceiver
    include Syncable
    
    extend Forwardable
    
    attr_reader :clock,
                :sequence
                
    attr_accessor :channel
    
    def_delegators :clock, :join, :start
    
    def_delegators :sequence, 
                     :gate, 
                     :gate=, 
                     :interval, 
                     :interval=,
                     :pattern_offset,
                     :pattern_offset=,
                     :pattern,
                     :pattern=,
                     :pointer,
                     :resolution,
                     :range,
                     :range=, 
                     :rate, 
                     :rate=,
                     :reset,
                     :transpose
                     
    #
    # a numeric tempo rate (BPM), or unimidi input is required by the constructor.  in the case that you use a MIDI input, it will be used as a clock source
    #
    # the constructor also accepts a number of options
    #       
    # * channel: restrict input messages to the given MIDI channel. will operate on all input sources
    #
    # * gate: <em>gate</em> refers to how long the arpeggiated notes will be held out. the <em>gate</em> value is a percentage based on the rate.  if the rate is 4, then a gate of 100 is equal to a quarter note. the default <em>gate</em> is 75. <em>Gate</em> must be positive and less than 500
    #
    # * interval: the arpeggiator increments the <em>pattern</em> over <em>interval</em> scale degrees <em>range</em> times.  the default <em>interval</em> is 12, meaning one octave above the current note. <em>interval</em> may be any positive or negative number
    #  
    # * midi: this can be a unimidi input or output. will accept a single device or an array
    #
    # * pattern_offset: <em>pattern_offset</em> n means that the arpeggiator will begin on the nth note of the sequence (but not omit any notes). the default <em>pattern_offset</em> is 0.
    # 
    # * pattern: A Pattern object that computes the contour of the arpeggiated melody
    #    
    # * range: the arpeggiator increments the <em>pattern</em> over <em>interval</em> scale degrees <em>range</em> times. <em>range</em> must be 0 or greater. the default <em>range</em> is 3
    #
    # * rate: <em>rate</em> is how fast the arpeggios will be played. the default is 8, which is an eighth note. rate may be 0 (whole note) or greater but must be equal to or less than <em>resolution</em>
    #  
    # * resolution: the resolution of the arpeggiator (numeric notation)    
    #    
    def initialize(tempo_or_input, options = {}, &block)
      @mute = false      
      @actions = { :tick => nil }
      
      @channel = options[:channel]      
      resolution = options[:resolution] || 128
      
      @clock = ClockStack.new(tempo_or_input, resolution, options)
      
      initialize_midi_io(options[:midi]) unless options[:midi].nil?
      initialize_sync(options)
      
      @sequence = ArpeggiatorSequence.new(resolution, options)

      bind_events(&block)
    end
    
    # add input notes. takes a single note or an array of notes
    def add(notes)
      notes = [notes].flatten
      notes = channel_filter(notes) unless @channel.nil?
      @sequence.add(notes)
    end
    
    # remove input notes. takes a single note or an array of notes
    def remove(notes)
      notes = [notes].flatten
      notes = channel_filter(notes) unless @channel.nil?
      @sequence.remove(notes)
    end
    
    # toggle mute on this arpeggiator
    def toggle_mute
      muted? ? unmute : mute
    end
    
    # mute this arpeggiator
    def mute
      @mute = true
      send_pending_note_offs
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
      send_pending_note_offs             
    end
    
    # send all of the note off messages in the queue
    def send_pending_note_offs
      data = @sequence.pending_note_offs.map { |msg| msg.to_bytes }.flatten.compact
      @midi_destinations.each { |o| o.puts(data) } unless data.empty?
    end
    
    private
    
    def initialize_sync(options = {})
      sync_to = [options[:sync_to]].flatten.compact      
      sync_to.each { |arp| sync_to(arp) }
      slaves = [options[:slave]].flatten.compact
      slaves.each { |arp| sync(arp) }
    end
    
    def update_clock
      @clock.update_destinations(@midi_destinations)
      @clock.ensure_tick_action(self, &@actions[:tick]) unless @actions[:tick].nil?
    end
    alias_method :on_midi_destinations_updated, :update_clock
    
    def channel_filter(notes)
      notes.map { |n| n if n.channel == @channel }.flatten.compact
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
            emit_midi(data) if emit_midi? && !data.empty?
            yield(msgs) unless block.nil?
          end
        end
      end
      update_clock       
    end
  
  end
  
end
