require "helper"

class Diamond::OSC::ControllerTest < Test::Unit::TestCase

  context "OSC::Server" do

    context "#start" do

      setup do
        @controller = Diamond::OSC::Controller.new(Object.new, [], :port => 8000)
      end

      should "start server" do
        ::OSC::EMServer.any_instance.expects(:run).once
        @controller.start
      end

    end

    context "#initialize_map" do

      setup do
        @map = [
         { :property => :interval, :address => "/1/rotaryA", :value => (0..1.0) },
         { :property => :transpose, :address => "/1/rotaryB" }
        ]
        @addresses = @map.map { |mapping| mapping[:address] }
      end

      should "assign map" do
        ::OSC::EMServer.any_instance.expects(:add_method).times(@map.size).with do |arg| 
          assert @addresses.include?(arg)
        end
        @controller = Diamond::OSC::Controller.new(Object.new, @map, :port => 8000)
      end
    end

  end

end

