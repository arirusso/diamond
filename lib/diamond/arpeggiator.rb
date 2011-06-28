#!/usr/bin/env ruby
module Diamond
  
  class Arpeggiator
    
    extend Forwardable
    
    attr_reader :clock,
                :midi_sources,
                :sequencer
    
    def_delegators :clock, 
                     :start,
                     :sync_from,
                     :sync_to, 
                     :<<
    def_delegators :sequencer, 
                     :add, 
                     :remove, 
                     :gate, 
                     :gate=, 
                     :interval, 
                     :interval=,
                     :offset,
                     :offset=,
                     :pattern,
                     :pattern=,
                     :pointer,
                     :resolution,
                     :range,
                     :range=, 
                     :rate, 
                     :rate=
    #
    # a tempo rate (BPM) is required by the constructor
    #
    # the constructor also accepts a number of options
    #
    # * gate: <em>gate</em> refers to how long the arpeggiated notes will be held out. the value is a percentage based on the rate.  if the rate is 4 (quarter note) then a gate of 100 is equal to a quarter note. the default gate value is 75 (dotted eighth note). must be positive and less than 500
    # * interval: the default <em>interval</em> is 12, meaning one octave above the current note.  the arpeggiator increments the <em>pattern</em> over <em>interval</em> scale degrees <em>range</em> times.  <em>interval</em> may also be negative  
    # * midi: this can be a unimidi input or output. will accept a single device or an array
    # * offset: <em>offset</em> n means that the arpeggiator will begin on the nth note of the sequence (but not omit any notes). the default <em>offset</em> is 0. 
    # * pattern: this is a Pattern object that computes the shape of the arpeggiated melody    
    # * range: the arpeggiator increments the <em>pattern</em> over <em>interval</em> scale degrees <em>range</em> times. <em>range</em> must be 0 or greater. the default <em>range</em> is 3
    # * rate: rate is how fast the arpeggios will be played. the default is 8, which is an eighth note. rate may be 0 (whole note) or greater but must be equal to or less than <em>resolution</em>  
    # * resolution: the resolution of the arpeggiator -- lower this number for better performance when running multiple arpeggiators    
    #
    def initialize(tempo, options = {}, &block)
      @mute = false
      @midi_sources = {}
      resolution = options[:resolution] || 128
      quarter_note = resolution / 4
      
      initialize_midi_io(options[:midi]) unless options[:midi].nil?
      
      @sequencer = Sequencer.new(resolution, options)
      initialize_clock(tempo, resolution, options)
      bind_events(&block)
    end
    
    # toggle mute on this arpeggiator
    def toggle_mute
      @mute = !@mute
    end
    
    # mute this arpeggiator
    def mute
      @mute = true
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
      data = @sequencer.pending_note_offs.map { |msg| msg.to_bytes }
      @midi_destinations.each { |o| o.puts(data) } unless data.empty?      
    end
    
    def add_midi_source(source)
      initialize_midi_source(source)
    end
    
    def remove_midi_source(source)
      @midi_sources[source].stop
      @midi_sources.delete(source)
    end
    
    private
    
    def initialize_clock(tempo, resolution, options)
      sync_to = [options[:sync_to]].flatten.compact
      children = [options[:children]].flatten.compact
      @clock = Topaz::Tempo.new(tempo, :sync_to => sync_to, :children => children)
      dif = resolution / @clock.interval  
      @clock.interval = @clock.interval * dif
    end
    
    def initialize_midi_io(devices)
      devices = [devices].flatten
      @midi_destinations = devices.find_all { |d| d.type == :output }
      sources = devices.find_all { |d| d.type == :input }   
      sources.each { |source| initialize_midi_source(source) }
    end
    
    def initialize_midi_source(source)
      listener = MIDIEye::Listener.new(source)
      listener.listen_for(:class => MIDIMessage::NoteOn) { |event| add(event[:message]) }
      listener.listen_for(:class => MIDIMessage::NoteOff) { |event| remove(event[:message]) }
      listener.start(:background => true)
      @midi_sources[source] = listener
    end
    
    def bind_events(&block)
      @clock.on_tick do 
        @sequencer.with_next do |msgs|
          data = msgs.map { |msg| msg.to_bytes }.flatten
          @midi_destinations.each { |o| o.puts(data) } unless data.empty?
          yield(msgs) unless block.nil? || muted?
        end
      end 
    end
  
  end
  
end
