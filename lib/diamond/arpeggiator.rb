#!/usr/bin/env ruby
module Diamond
  
  class Arpeggiator < DiamondEngine::MIDISequencer
    
    include DiamondEngine::ReceivesMIDI
    include DiamondEngine::ReceivesOSC
    
    extend Forwardable
    
    attr_reader :sequence
    
    def_delegators :sequence, 
                   :gate,
                   :gate=,
                   :interval,
                   :interval=,
                   :pattern,
                   :pattern=,
                   :range,
                   :range=,
                   :rate,
                   :rate=,
                   :pattern_offset,
                   :pattern_offset=,
                   :resolution,
                   :resolution=,
                   :transpose,
                   :transpose=
                
    DefaultChannel = 0
    DefaultVelocity = 100
                         
    #
    # a numeric tempo rate (BPM), or unimidi input is required by the constructor (<tt>tempo_or_input</tt>).  in the case that you use a MIDI input, it will be used as a clock source
    #
    # the constructor also accepts a number of options -- these options are all editable after initialization by calling for example <em>arpeggiator.gate = 4</em>
    #
    # * <b>channel</b> (or <b>input_channel</b>) - only respond to input messages to the given MIDI channel. will operate on all input sources
    #
    # * <b>gate</b> - <tt>gate</tt> refers to how long the arpeggiated notes will be held out. the <tt>gate</tt> value is a percentage based on the rate.  if the rate is 4, then a gate of 100 is equal to a quarter note. the default <tt>gate</tt> is 75. <tt>Gate</tt> must be positive and less than 500
    #
    # * <b>interval</b> - the arpeggiator increments the <tt>pattern</tt> over <tt>interval</tt> scale degrees <tt>range</tt> times.  the default <tt>interval</tt> is 12, meaning one octave above the current note. <tt>interval</tt> may be any positive or negative number
    #
    # * <b>midi</b> - this can be a unimidi input or output. will accept a single device or an array
    #
    # * <b>midi_clock_output</b> - should this Arpeggiator output midi clock? defaults to false
    #
    # * <b>output_channel</b> - send output messages to the given MIDI channel despite what channel the input notes were intended for.
    #
    # * <b>pattern_offset</b> - <tt>pattern_offset</tt> n means that the arpeggiator will begin on the nth note of the sequence (but not omit any notes). the default <tt>pattern_offset</tt> is 0.
    # 
    # * <b>pattern</b> - A Pattern object that computes the contour of the arpeggiated melody
    #
    # * <b>range</b> - the arpeggiator increments the <tt>pattern</tt> over <tt>interval</tt> scale degrees <tt>range</tt> times. <tt>range</tt> must be 0 or greater. the default <tt>range</tt> is 3
    #
    # * <b>rate</b> - <tt>rate</tt> is how fast the arpeggios will be played. the default is 8, which is an eighth note. rate may be 0 (whole note) or greater but must be equal to or less than <tt>resolution</tt>
    #
    # * <b>resolution</b> - the resolution of the arpeggiator (numeric notation)    
    #    
    def initialize(tempo_or_input, options = {}, &block)
      devices = [(options[:midi] || [])].flatten
      resolution = options[:resolution] || 128
      rx_channel = options[:rx_channel]
      tx_channel = options[:tx_channel] || options[:channel]
      
      initialize_midi_input(get_inputs(devices), rx_channel)
      initialize_sequence(resolution, options)  

      super(tempo_or_input, options.merge({ :sequence => @sequence }))
      self.tx_channel = tx_channel unless tx_channel.nil?
      
      initialize_osc_receiver(options[:osc_receive_port], options[:osc_map]) unless options[:osc_receive_port].nil? || options[:osc_map].nil?
      
      edit(&block) unless block.nil?
    end
    
    # add input notes. takes a single note or an array of notes
    def add(notes, options = {})
      notes = [notes].flatten
      notes = sanitize_input_notes(notes, MIDIMessage::NoteOn, options)
      @sequence.add(notes)
    end
    alias_method :<<, :add
    
    # remove input notes. takes a single note or an array of notes
    def remove(notes, options = {})
      notes = [notes].flatten
      notes = sanitize_input_notes(notes, MIDIMessage::NoteOff, options)
      @sequence.remove(notes)
    end
    
    # remove all input notes
    def remove_all
      @sequence.remove_all
    end
    alias_method :clear, :remove_all
    
    def omni_on
      @input_channel_filter = nil
      @input_process.delete_if { |p| p.name == :input_channel }
    end

    # set the midi channel to restrict input messages to
    # other messages will be ignored     
    def rx_channel=(val)
      @input_channel_filter.nil? ? initialize_rx_channel(val) : @input_channel_filter.bandwidth = val
    end
    
    # midi channel that input messages are restricted to
    # other messages are ignored
    # when nil, the arpeggiator accepts all channels 
    def rx_channel
      @input_channel_filter.nil? ? nil : @input_channel_filter.bandwidth
    end
        
    # set the midi channel to restrict output messages to 
    # all messages will be converted to this channel
    def tx_channel=(val)
      @output_channel_processor.nil? ? initialize_tx_channel(val) : @output_channel_processor.range = val
    end
    alias_method :channel=, :tx_channel=
    
    # midi channel that output messages are converted to
    # when nil, messages retain whatever channel the input message that they 
    # were derived from had
    def tx_channel
      @output_channel_processor.nil? ? nil : @output_channel_processor.range
    end
    
    protected
    
    def process_input(msgs)
      @input_process.process([msgs].flatten)
    end
         
    private

    def initialize_tx_channel(output_channel)
      @output_channel_processor = MIDIMessage::Process::Limit.new(:channel, output_channel, :name => :output_channel)
      @output_process << @output_channel_processor
    end
    
    # returns only valid inputs
    def get_inputs(devices)
      devices.find_all { |d| d.respond_to?(:type) && d.type == :input && d.respond_to?(:gets) }.compact
    end
    
    # initialize the arpeggiator sequence
    def initialize_sequence(resolution, options = {})
      @sequence = ArpeggiatorSequence.new(resolution, options)
      @sequence.transpose(options[:transpose]) unless options[:transpose].nil?    
    end
    
    def initialize_midi_input(devices, rx_channel)
      @input_process = DiamondEngine::ProcessChain.new
      self.rx_channel = rx_channel unless rx_channel.nil?
      initialize_midi_receiver(get_inputs(devices))
      initialize_midi_note_listener
    end
    
    def initialize_rx_channel(channel)
      @input_channel_filter = MIDIMessage::Process::Filter.new(:channel, channel, :name => :input_channel)
      @input_process << @input_channel_filter
    end
    
    def sanitize_input_notes(notes, klass, options)
      channel = options[:channel] || DefaultChannel
      velocity = options[:velocity] || DefaultVelocity
      notes = notes.map do |note|
        note.kind_of?(String) ? klass[note].new(channel, velocity) : note
      end.compact
      process_input(notes)
    end
        
    def initialize_midi_note_listener  
      receive_midi(:add_note, :class => MIDIMessage::NoteOn) { |this, event| this.add(event[:message]) }
      receive_midi(:remove_note, :class => MIDIMessage::NoteOff) { |this, event| this.remove(event[:message]) }
    end
  
  end
  
end