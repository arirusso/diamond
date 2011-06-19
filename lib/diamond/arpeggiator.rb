#!/usr/bin/env ruby
module Diamond
  
  class Arpeggiator
    
    attr_reader :gate,
                :interval,
                :pattern,
                :range,
                :pointer
    
    def initialize(options = {})
      @interval = options[:interval] || 12
      @range = options[:range] || 3
      #@pattern = options[:pattern] || Pattern.from_yaml(filename).first
      @notes = []
      @pattern = []
      
      @pointer = 0
      
      update_sequence
    end
    
    def step
      @pointer = (@pointer >= (@sequence.length - 1)) ? 0 : @pointer + 1
    end
    
    def add_notes(notes)
      @notes += [notes].flatten
      update_sequence
    end
    
    def remove_notes(notes)
      [notes].flatten.each { |n| @notes.delete(n) }
      update_sequence
    end
    
    def current
      @sequence[@pointer]
    end
    
    def gate=(num)
      @gate = num
      update_sequence
    end

    def interval=(num)
      @interval = num
      update_sequence
    end
    
    def range=(num)
      @range = num
      update_sequence
    end
        
    private
    
    def update_sequence
      @sequence = []
      @range.times do |r|
        @pattern.each do |p|
          @sequence += @notes.map { |n| n+ (12*(r+1)) }
        end
      end
    end
      
  end
  
end
