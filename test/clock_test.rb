require "helper"

class Diamond::ClockTest < Test::Unit::TestCase

  context "Clock" do

    setup do
      @clock = Diamond::Clock.new(120)
    end

    context "Clock#tempo" do

      should "get tempo" do
        assert_equal 120, @clock.tempo
      end

    end

    context "Clock#tempo=" do

      should "set tempo" do
        @clock.tempo = 58
        assert_equal 58, @clock.tempo
      end

    end

  end

end


