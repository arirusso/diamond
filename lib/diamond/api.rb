module Diamond

  module API

    module MIDI

      def self.included(base)
        base.send(:extend, Forwardable)
        base.send(:def_delegators, 
                  :@midi,
                  :mute,
                  :mute=,
                  :omni_on, 
                  :rx_channel, 
                  :receive_channel,
                  :rx_channel=,
                  :receive_channel=,
                  :toggle_mute,
                  :tx_channel, 
                  :transmit_channel,
                  :tx_channel=,
                  :transmit_channel=
                 )
      end

      def add_midi_source(source)
        @midi.inputs << source
      end

      def remove_midi_source(source)
        @midi.inputs.delete(source)
      end

      def midi_sources
        @midi.inputs
      end

      def mute?
        @midi.output.mute?
      end
      alias_method :muted?, :mute?

    end

    module Sequence

      def self.included(base)
        base.send(:extend, Forwardable)
        base.send(:def_delegators,
                  :@sequence, 
                  :sequence, 
                  :gate,
                  :gate=,
                  :interval,
                  :interval=,
                  :pattern,
                  :pattern=,
                  :range,
                  :range=,
                  :rate,
                  :rate=,
                  :pattern_offset,
                  :pattern_offset=,
                  :remove_all,
                  :resolution,
                  :resolution=,
                  :transpose,
                  :transpose=
                 )
        base.send(:alias_method, :clear, :remove_all)
      end

    end

  end
end
