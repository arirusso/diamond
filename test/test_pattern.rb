#!/usr/bin/env ruby

require 'helper'

class PatternTest < Test::Unit::TestCase

  include Diamond
  include TestHelper
  
  def test_new_pattern
    pattern = Pattern.new("test") do |r, i|
      a = []
      0.upto(r) { |n| a << (n * i) }
      a
    end
    result = pattern.compute(2, 12)
    assert_equal([0, 12, 24], result)
  end
  
  def test_range_and_interval
    pattern = Pattern["Up"]
    result = pattern.compute(3, 7)
    assert_equal(4, result.length)   
    assert_equal([0, 7, 14, 21], result)            
  end
    
  def test_up
    pattern = Pattern["Up"]
    result = pattern.compute(2, 12)
    assert_equal([0, 12, 24], result)    
  end
  
  def test_down
    pattern = Pattern["Down"]
    result = pattern.compute(2, 12)
    assert_equal([24, 12, 0], result)    
  end

  def test_updown
    pattern = Pattern["UpDown"]
    result = pattern.compute(3, 12)
    assert_equal([0, 12, 24, 36, 24, 12, 0], result)    
  end

  def test_downup
    pattern = Pattern["DownUp"]
    result = pattern.compute(3, 12)
    assert_equal([36, 24, 12, 0, 12, 24, 36], result)    
  end
      
end