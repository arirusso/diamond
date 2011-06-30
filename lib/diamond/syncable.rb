#!/usr/bin/env ruby
module Diamond
  
  module Syncable
    
    def self.included(base)
      base.send(:attr_reader, :sync_set)
    end
    
    # sync to another syncable
    def sync_to(syncable)
      @sync_queue << syncable            
    end
        
    # sync another syncable to this one
    def sync(syncable)
      syncable.sync_to(self)
    end
    
    def unsync_to(syncable)
      @sync_set.delete(syncable)
      syncable.clock.stop
      on_sync_updated if respond_to?(:on_sync_updated)
    end
    
    private
    
    def initialize_syncable(sync_to, slave)
      @sync_queue ||= []
      @sync_set ||= []
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
      @sync_queue.each do |syncable| 
        @sync_set << syncable
        syncable.clock.stop
      end
      on_sync_updated if respond_to?(:on_sync_updated)
    end
          
  end
  
end
