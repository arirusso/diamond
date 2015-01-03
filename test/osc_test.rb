require "helper"

class Diamond::OSCTest < Minitest::Test

  context "OSC" do

    context "#enable_parameter_control" do

      setup do
        @map = [
         { :property => :interval, :address => "/1/rotaryA", :value => (0..1.0) },
         { :property => :transpose, :address => "/1/rotaryB" }
        ]
        @addresses = @map.map { |mapping| mapping[:address] }
        @osc = Diamond::OSC.new(:server_port => 8000)
        ::OSC::EMServer.any_instance.expects(:run).once
        ::OSC::EMServer.any_instance.expects(:add_method).times(@map.size).with do |arg|
          assert @addresses.include?(arg)
        end
      end

      teardown do
        ::OSC::EMServer.any_instance.unstub(:run)
        ::OSC::EMServer.any_instance.unstub(:add_method)
      end

      should "start server" do
        @osc.enable_parameter_control(Object.new, @map)
      end

      should "assign map" do
        @osc.enable_parameter_control(Object.new, @map)
      end

    end

  end

end
