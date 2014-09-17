require "helper"

class Diamond::ApeggiatorTest < Test::Unit::TestCase

  context "Arpeggiator" do

    context "#initialize" do

      should "have defaults" do
        @arpeggiator = Diamond::Arpeggiator.new
        assert_equal 8, @arpeggiator.rate
        assert_equal 3, @arpeggiator.range    
        assert_equal 12, @arpeggiator.interval  
      end

      should "allow setting params" do
        @arpeggiator = Diamond::Arpeggiator.new(:interval => 7, :range => 4, :rate => 16)
        assert_equal 16, @arpeggiator.rate
        assert_equal 4, @arpeggiator.range    
        assert_equal 7, @arpeggiator.interval  
      end

      should "allow passing in input" do
        @input = $test_device[:input]
        @arpeggiator = Diamond::Arpeggiator.new(:midi => @input)
        assert_not_empty @arpeggiator.midi_sources
        assert @arpeggiator.midi_sources.include?(@input) 
      end

    end

  end

end
