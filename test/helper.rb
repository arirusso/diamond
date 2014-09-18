dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift dir + "/../lib"

require "test/unit"
require "mocha/test_unit"
require "shoulda-context"
require "diamond"

module TestHelper
  
  def self.select_devices
    $test_device ||= {}
    { :input => UniMIDI::Input, :output => UniMIDI::Output }.each do |type, klass|
      $test_device[type] = klass.gets
    end
  end
     
end

TestHelper.select_devices

# Stub out OSC networking
::EM.stubs(:run).returns(:true)
