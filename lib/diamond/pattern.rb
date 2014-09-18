module Diamond

  # Pattern that the sequence is derived from given the parameters and input
  class Pattern

    attr_reader :name

    # @param [String, Symbol] name A name to identify the pattern by eg "up/down"
    # @param [Proc] block The pattern procedure, which should return an array of scale degree numbers.  
    #                     For example, given the arguments (3, 7) the "Up" pattern will produce [0, 7, 14, 21]
    def initialize(name, &block)
      @name = name
      @proc = block
    end

    # Compute scale degrees using the pattern with the given range and interval
    # @param [Fixnum] range
    # @param [Interval] interval
    # @return [Array<Fixnum>]
    def compute(range, interval)
      @proc.call(range, interval)
    end

    # All patterns
    # @return [Array<Pattern>]
    def self.all
      @patterns
    end

    # Find a pattern by its name (case insensitive)
    # @param [String, Symbol] name
    # @return [Pattern]
    def self.find(name)
      all.find { |pattern| pattern.name.to_s.downcase == name.to_s.downcase }
    end

    @patterns = []
    class << self 
      alias_method :[], :find

      attr_reader :patterns
    end

    # Standard preset patterns
    module Presets

      Pattern.patterns << Pattern.new("Up") do |range, interval|
        0.upto(range).map { |num| num * interval }
      end

      Pattern.patterns << Pattern.new("Down") do |range, interval|
        range.downto(0).map { |num| num * interval }
      end

      Pattern.patterns << Pattern.new("UpDown") do |range, interval|
        up = 0.upto(range).map { |num| num * interval }
        down = [(range - 1), 0].max.downto(0).map { |num| num * interval }
        up + down
      end

      Pattern.patterns << Pattern.new("DownUp") do |range, interval|
        down = range.downto(0).map { |num| num * interval }
        up = 1.upto(range).map { |num| num * interval }
        down + up
      end

    end

  end

end
