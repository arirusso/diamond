#!/usr/bin/env ruby
module Diamond
  
  class Pattern
    
    attr_reader :name
    
    def initialize(name, &proc)
      @name = name
      @proc = proc      
    end
    
    def compute(range)
      @proc.call(range)
    end
    
    def self.all
      ensure_populated
      @patterns
    end
    
    def self.find(name)
      all.find { |p| p.name == name }
    end
    class << self 
      alias_method :[], :find
    end
    
    private
    
    def self.ensure_populated
      @patterns ||= []
      return unless @patterns.empty?
      
      @patterns << Pattern.new("Up") do |r| 
          a = []
          0.upto(r) { |i| a << i }
          a
      end
        
      @patterns << Pattern.new("Down") do |r|
          a = []
          r.downto(0) { |i| a << i }
          a
        end
        
      @patterns << Pattern.new("UpDown") do |r|
          a = []
          0.upto(r) { |i| a << i }
          r.downto(0) { |i| a << i }
          a
      end
        
    end
    
  end
  
end
