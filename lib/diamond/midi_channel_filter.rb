#!/usr/bin/env ruby
module Diamond

  module MIDIChannelFilter
    
    def self.included(base)
      base.send(:attr_accessor, :input_channel, :output_channel)
    end

    def input_channel_filter(notes)
      @input_channel.nil? ? notes : notes.find_all { |note| note.channel == @input_channel }
    end   
    
    def output_channel_filter(msgs)
      @output_channel.nil? ? msgs : msgs.map { |msg| msg.channel = @output_channel; msg } 
    end     
    
    private
    
    def initialize_midi_channel_filter(input_channel, output_channel)
      @input_channel ||= input_channel
      @output_channel ||= output_channel
    end
    
  end
  
end
