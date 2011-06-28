#!/usr/bin/env ruby

module Diamond

  Pattern.patterns << Pattern.new("Up") do |r, i|
    a = []
    0.upto(r) { |n| a << (n * i) }
    a
  end

  Pattern.patterns << Pattern.new("Down") do |r, i|
    a = []
    r.downto(0) { |n| a << (n * i) }
    a
  end

  Pattern.patterns << Pattern.new("UpDown") do |r, i|
    a = []
    0.upto(r) { |n| a << (n * i) }
    [(r-1), 0].max.downto(0) { |n| a << (n * i) }
    a
  end

  Pattern.patterns << Pattern.new("DownUp") do |r, i|
    a = []
    r.downto(0) { |n| a << (n * i) }
    1.upto(r) { |n| a << (n * i) }
    a
  end

end