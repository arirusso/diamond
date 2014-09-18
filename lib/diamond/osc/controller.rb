require "osc-ruby"
require "osc-ruby/em_server"

module Diamond

  module OSC

    # Control the instrument via OSC
    class Controller

      # @param [Arpeggiator] subject
      # @param [Array<Hash>] map
      # @param [Hash] options
      # @option options [Boolean] :debug Whether to send debug output
      # @option options [Fixnum] :port The port to listen on
      def initialize(subject, map, options = {})
        @subject = subject
        @debug = !!options[:debug]
        initialize_server(options.fetch(:port, 8000))
        initialize_map(map)
      end

      # Start the server
      # @return [Thread]
      def start
        @thread = Thread.new do 
          begin
            @server.run
          rescue Exception => exception
            Thread.main.raise(exception)
          end
        end
        @thread.abort_on_exception = true
        @thread
      end

      private

      # Initialize the server object
      # @param [Fixnum] port
      # @return [::OSC::EMServer]
      def initialize_server(port)
        @server = ::OSC::EMServer.new(port)
      end

      # Initialize the control mapping
      # @param [Array<Hash>] map
      # @return [Boolean]
      def initialize_map(map)
        maps = map.map do |item|
          property = item[:property]
          from_range = item[:value] || (0..1.0)
          to_range = SequenceParameters::RANGE[property]
          @server.add_method(item[:address]) do |message|
            value = message.to_a[0]
            value = Scale.transform(value).from(from_range).to(to_range)
            puts "OSC: Arpeggiator (#{@subject.object_id}) #{property}= #{value}" if @debug
            @subject.send("#{property}=", value)
            true
          end
          true
        end
        maps.any?
      end

    end

  end
end
