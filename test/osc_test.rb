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
      end

      should "start server" do
        ::OSC::EMServer.any_instance.expects(:run).once
        @osc.enable_parameter_control(Object.new, @map)
        ::OSC::EMServer.any_instance.unstub(:run)
      end

      should "assign map" do
        ::OSC::EMServer.any_instance.expects(:add_method).times(@map.size).with do |arg|
          assert @addresses.include?(arg)
        end
        @osc.enable_parameter_control(Object.new, @map)
        ::OSC::EMServer.any_instance.unstub(:add_method)
      end

    end

  end

end
