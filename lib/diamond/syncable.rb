#!/usr/bin/env ruby
module Diamond
  
  module Syncable
    
    # sync to another syncable
    def sync_to(syncable)
      syncable.sync(self)
    end
        
    # sync another syncable to this one
    # TO DO **** this needs to happen on a reasonable downbeat always
    def sync(syncable)
      @clock << syncable.clock
      on_sync_updated if respond_to?(:on_sync_updated)
    end
    alias_method :<<, :sync
    
    def unsync(syncable, options = {})
      if options[:quantize]
        # TO DO
      end
      @clock.remove(syncable.clock)
      on_sync_updated if respond_to?(:on_sync_updated)
    end
          
  end
  
end
