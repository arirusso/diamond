#!/usr/bin/env ruby

module TestHelper::Config

  include UniMIDI

  # adjust these constants to suit your hardware configuration
  # before running tests

  TestInput = Input.first # this is the device you wish to use to test input
  TestOutput = Output.first # likewise for output

  #puts "connect #{TestInput.name} (#{TestInput.id}) to #{TestOutput.name} (#{TestOutput.id}) and press enter"
  #$stdin.gets.chomp
end