#!/usr/bin/env ruby
module Diamond
  
  module Syncable
    
    def self.included(base)
      base.send(:attr_reader, :sync_set)
    end
    
    # sync to another syncable
    def sync(syncable)
      @sync_queue << syncable                 
    end
        
    # sync another syncable to this one
    def sync_to(syncable)
      syncable.sync(self)
    end
    
    def unsync(syncable)
      @sync_set.delete(syncable)
      syncable.unpause_clock
      on_sync_updated
    end
    
    def unsync_from(syncable)
      syncable.unsync(self)
    end
    
    def sync_tick
      @actions[:tick].call
    end
    
    def pause_clock
      @clock.pause
    end
    
    def unpause_clock
      @clock.unpause
    end
    
    private
    
    def initialize_syncable(sync_to, sync)
      @sync_queue ||= []
      @sync_set ||= []
      unless sync_to.nil?
        sync_to = [sync_to].flatten.compact      
        sync_to.each { |syncable| sync_to(syncable) }
      end
      unless sync.nil?
        sync = [sync].flatten.compact
        sync.each { |syncable| sync(syncable) }
      end
    end
    
    def activate_sync_queue
      updated = false
      @sync_queue.each do |syncable| 
        @sync_set << syncable
        syncable.pause_clock
        @sync_queue.delete(syncable)
        updated = true
      end      
      on_sync_updated if updated
    end
          
  end
  
end
