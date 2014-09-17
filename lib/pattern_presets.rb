module Diamond
  
  # the Proc should return a set of scale degrees such as
  # given (3, 7) the "Up" pattern will return [0, 7, 14, 21]

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
