#!/usr/bin/env ruby
module Diamond
  
  module Syncable
    
     # sync to another arpeggiator
    def sync_to(arp)
      arp.sync(self)
    end
        
    # accept sync another arpeggiator to this one
    # TO DO **** this needs to happen on a reasonable downbeat always
    def sync(arp)
      @clock << arp.clock
      update_clock
    end
    alias_method :<<, :sync
    
    def unsync(arp, options = {})
      if options[:quantize]
        # TO DO
      end
      @clock.remove(arp.clock)
      update_clock
    end
          
  end
  
end
