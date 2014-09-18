module Diamond

  # Enable the instrument to use OSC
  module OSC

    # An access point for dealing with all OSC functionality for the instrument
    class Node

      # @param [Hash] options
      # @option options [Boolean] :debug Whether to send debug output
      # @option options [Fixnum] :server_port The port to listen on (default: 8000)
      def initialize(options = {})
        @debug = options.fetch(:debug, false)
        port = options.fetch(:server_port, 8000)
        @server = ::OSC::EMServer.new(port)
      end

      # Enable controlling the instrument via OSC
      # @param [Object] subject The object to operate on when messages are received
      # @param [Array<Hash>] map
      # @return [Boolean]
      def enable_parameter_control(subject, map)
        start_server
        maps = map.map do |item|
          property = item[:property]
          from_range = item[:value] || (0..1.0)
          to_range = SequenceParameters::RANGE[property]
          @server.add_method(item[:address]) do |message|
            value = message.to_a[0]
            value = Scale.transform(value).from(from_range).to(to_range)
            puts "[DEBUG]: OSC: #{property}= #{value}" if @debug
            subject.send("#{property}=", value)
            true
          end
          true
        end
        maps.any?     
      end

      private

      # Start the server
      # @return [Thread]
      def start_server
        @thread = Thread.new do
          begin
            EM.epoll
            EM.run { @server.run }
          rescue Exception => exception
            Thread.main.raise(exception)
          end
        end
        @thread.abort_on_exception = true
        @thread
      end

    end

    # Shortcut to Diamond::OSC::Node.new
    def self.new(*args)
      Node.new(*args)
    end

  end
end

# Patch the OSC module
#
module OSC
  class EMServer

    def run
      open
    end

    def open
      EM::open_datagram_socket("0.0.0.0", @port, Connection)
    end

  end
end

module EventMachine
  module WebSocket
    def self.start(options, &blk)
      #EM.epoll
      #EM.run {
        trap("TERM") { stop }
        trap("INT")  { stop }

        run(options, &blk)
      #}
    end

    def self.run(options)
      host, port = options.values_at(:host, :port)
      EM.start_server(host, port, Connection, options) do |c|
        yield c
      end
    end
  end
end
