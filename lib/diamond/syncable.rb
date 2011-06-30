#!/usr/bin/env ruby
module Diamond
  
  module Syncable
    
    # sync to another syncable
    def sync_to(syncable)
      syncable.sync(self)
    end
        
    # sync another syncable to this one
    def sync(syncable, options = {})
      @sync_queue << syncable.clock      
    end
    
    def unsync(syncable)
      @clock.remove(syncable.clock)
      on_sync_updated if respond_to?(:on_sync_updated)
    end
    
    private
    
    def initialize_syncable(sync_to, slave)
      @sync_queue ||= []
      unless sync_to.nil?
        sync_to = [sync_to].flatten.compact      
        sync_to.each { |syncable| sync_to(syncable) }
      end
      unless slave.nil?
        slaves = [slave].flatten.compact
        slaves.each { |syncable| sync(syncable) }
      end
    end
    
    def activate_sync_queue
      @sync_queue.each { |clock| @clock << clock }
      on_sync_updated if respond_to?(:on_sync_updated)
    end
          
  end
  
end
