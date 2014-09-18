require "helper"

class PatternTest < Test::Unit::TestCase

  context "Pattern" do

    setup do
      ::OSC::EMServer.any_instance.stubs(:run).returns(:true)
    end

    context "#initialize" do

      should "create usable pattern" do
        pattern = Diamond::Pattern.new("test") do |range, interval|
          0.upto(range).map { |num| num * interval }
        end
        result = pattern.compute(2, 12)
        assert_equal [0, 12, 24], result
      end

    end

    context "#compute" do

      should "reflect range and interval" do
        pattern = Diamond::Pattern.find("Up")
        result = pattern.compute(3, 7)
        assert_equal 4, result.length
        assert_equal [0, 7, 14, 21], result        
      end

    end
    context "Presets" do

      should "populate Up" do
        pattern = Diamond::Pattern.find("Up")
        result = pattern.compute(2, 12)
        assert_equal [0, 12, 24], result    
      end

      should "populate Down" do
        pattern = Diamond::Pattern.find("Down")
        result = pattern.compute(2, 12)
        assert_equal [24, 12, 0], result  
      end

      should "populate UpDown" do
        pattern = Diamond::Pattern.find("UpDown")
        result = pattern.compute(3, 12)
        assert_equal [0, 12, 24, 36, 24, 12, 0], result   
      end

      should "populate DownUp" do
        pattern = Diamond::Pattern.find("DownUp")
        result = pattern.compute(3, 12)
        assert_equal [36, 24, 12, 0, 12, 24, 36], result   
      end

    end

  end

end
