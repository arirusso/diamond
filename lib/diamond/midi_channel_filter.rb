#!/usr/bin/env ruby
module Diamond

  module MIDIChannelFilter
    
    def self.included(base)
      base.send(:attr_reader, :input_channel, :output_channel)
    end

    def input_channel_filter(note)
      (@input_channel.nil? || note.channel == @input_channel) ? note : nil
    end   
    
    def output_channel_filter(msgs)
      msgs.each { |msg| msg.channel = @output_channel } unless @output_channel.nil?
    end     
    
    private
    
    def initialize_midi_channel_filter(input_channel, output_channel)
      @input_channel = input_channel
      @output_channel = output_channel
    end
    
  end
  
end
