module Diamond
  
  # Pattern that the sequence is derived from given the parameters and input
  class Pattern
    
    attr_reader :name
    
    # @param [String, Symbol] name A name to identify the pattern by eg "up/down"
    # @param [Proc] proc The pattern procedure
    def initialize(name, &proc)
      @name = name
      @proc = proc      
    end
    
    # Compute scale degrees using the pattern with the given range and interval
    # @param [Fixnum] range
    # @param [Interval] interval
    # @return [Array<Fixnum>]
    def compute(range, interval)
      @proc.call(range, interval)
    end
    
    # All patterns
    # @return [Array<Pattern>]
    def self.all
      @patterns
    end
    
    # Find a pattern by its name (case insensitive)
    # @param [String, Symbol] name
    # @return [Pattern]
    def self.find(name)
      all.find { |pattern| pattern.name.to_s.downcase == name.to_s.downcase }
    end
    
    @patterns = []
    class << self 
      alias_method :[], :find
      
      attr_reader :patterns
    end
        
  end
  
end
