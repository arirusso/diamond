$:.unshift(File.join("..", "lib"))

# A basic live coding setup
#
# Use this code in irb or some other live coding environment
#
# If you run this as a script, it will exit before doing anything
#

require "diamond"

@output = UniMIDI::Output.gets

options = {
  :gate => 90,
  :interval => 7,
  :midi => @output,
  :pattern => "UpDown",
  :range => 4,
  :rate => 8
}

c = Diamond::Clock.new(101)
a = Diamond::Arpeggiator.new(options)
c << a

chord = ["C3", "G3", "Bb3", "A4"]
a << chord

c.start
