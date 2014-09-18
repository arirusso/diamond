module Diamond

  # Convenience methods for the instrument
  module API

    # MIDI convenience methods
    module MIDI

      def self.included(base)
        base.send(:extend, Forwardable)
        base.send(:def_delegators, 
                  :@midi,
                  :<<,
                  :add,
                  :mute,
                  :mute=,
                  :omni_on, 
                  :remove,
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

      # Add a MIDI input
      # @param [UniMIDI::Input] source
      # @return [Array<UniMIDI::Input>]
      def add_midi_source(source)
        @midi.inputs << source
      end

      # Remove a MIDI input
      # @param [UniMIDI::Input] source
      # @return [Array<UniMIDI::Input>]
      def remove_midi_source(source)
        @midi.inputs.delete(source)
      end

      # MIDI inputs associated with this instrument
      # @return [Array<UniMIDI::Input>]
      def midi_sources
        @midi.inputs
      end

      # Is the instrument MIDI output muted?
      # @return [Boolean]
      def mute?
        @midi.output.mute?
      end
      alias_method :muted?, :mute?

    end

    # Convenience methods dealing with the sequence
    module Sequence

      def self.included(base)
        base.send(:extend, Forwardable)
        base.send(:def_delegators,
                  :@sequence, 
                  :sequence, 
                  :remove_all)
        base.send(:alias_method, :clear, :remove_all)
      end

    end

    # Convenience methods dealing with the sequence parameters
    module SequenceParameters

      def self.included(base)
        base.send(:extend, Forwardable)
        base.send(:def_delegators,
                  :@parameter, 
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
                  :resolution,
                  :resolution=,
                  :transpose,
                  :transpose=)
      end

    end

  end
end
