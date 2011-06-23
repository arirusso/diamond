#!/usr/bin/env ruby
module Diamond
  
  class Clock
    
    def initialize(*args, &block)
      @tempo = Topaz::Tempo(*args, &block)
      #@tempo.interval =
    end
    
  end
  
end
