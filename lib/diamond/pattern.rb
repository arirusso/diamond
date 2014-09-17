module Diamond
  
  class Pattern
    
    attr_reader :name
    
    def initialize(name, &proc)
      @name = name
      @proc = proc      
    end
    
    # compute scale degrees using the pattern with the given <em>range</em> and <em>interval</em>
    def compute(range, interval)
      @proc.call(range, interval)
    end
    
    # all patterns
    def self.all
      @patterns
    end
    
    # find a pattern by its name
    def self.find(name)
      all.find { |p| p.name.downcase == name.downcase }
    end
    
    @patterns = []
    class << self 
      alias_method :[], :find
      
      attr_reader :patterns
    end
        
  end
  
end
