module Diamond

  class ProcessChain
        
    include Enumerable 

    def initialize
      @processors = []
    end

    def each(&block)
      @processors.each(&block)
    end

    def <<(processor)
      @processors << processor
    end
    
    # Run all @processors on the given messages
    def process(messages)
      if @processors.empty?
        messages
      else
        processed = @processors.map do |processor|
          [messages].flatten.map { |message| processor.process(message) }
        end
        processed.flatten.compact
      end
    end
    
    # Find the processor with the given name
    def find_by_name(name)
      @processors.find { |process| process.name == name }
    end
          
  end
  
end

