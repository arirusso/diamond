#!/usr/bin/env ruby
module Diamond

  class MIDIChannelFilter
    
    attr_accessor :channel

    def process(notes)
      @channel.nil? ? notes : notes.find_all { |note| note.channel == @channel }
    end       
    
    def initialize(channel)
      @channel ||= channel
    end
    
  end
  
end
