#!/usr/bin/env ruby
module Diamond
  
  module Syncable
    
    # sync to another syncable
    def sync_to(syncable)
      syncable.sync(self)
    end
        
    # sync another syncable to this one
    def sync(syncable, options = {})
      quantize = options[:quantize] || -1
      index = quantize + 1
      @sync_queue[index] ||= []
      @sync_queue[index] << syncable.clock      
    end
    
    def unsync(syncable)
      @clock.remove(syncable.clock)
      on_sync_updated if respond_to?(:on_sync_updated)
    end
    
    private
    
    def initialize_syncable(options = {})
      @sync_queue ||= {}
      sync_to = [options[:sync_to]].flatten.compact      
      sync_to.each { |syncable| sync_to(syncable) }
      slaves = [options[:slave]].flatten.compact
      slaves.each { |syncable| sync(syncable) }
    end
    
    def activate_sync_queue
      nxt = @sync_queue.shift
      nxt.each { |clock| @clock << clock }
      on_sync_updated if respond_to?(:on_sync_updated)
    end
          
  end
  
end
