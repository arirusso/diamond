#Diamond

[MIDI arpeggiator](http://en.wikipedia.org/wiki/Arpeggiator#Arpeggiator) in Ruby

![diamond](http://img256.imageshack.us/img256/4514/diamondd.jpg)

##Features

* Classic arpeggiator functionality and patterns
* [OSC](http://en.wikipedia.org/wiki/Open_Sound_Control) and MIDI remote control
* MIDI clock IO
* Multiplex clocks and arpeggiators
* Suited to [live coding](http://en.wikipedia.org/wiki/Live_coding)
* Generative arpeggio patterns 

##Installation

`gem install diamond`
  
  or with Bundler, add this to your Gemfile
  
`gem "diamond"` 
  
##Usage

```ruby
require "diamond"
```

First, select a MIDI output using [unimidi](https://github.com/arirusso/unimidi). ([more about that...](http://tx81z.blogspot.com/2011/10/selecting-midi-device-with-unimidi.html))

```ruby
@output = UniMIDI::Output.gets
```

The Diamond arpeggiator has a number of [optional parameters](http://rubydoc.info/github/arirusso/diamond/master/Diamond/Arpeggiator:initialize).  For this example, here's a straightforward setup

```ruby
options = { 
  :gate => 90, 
  :interval => 7,
  :midi => @output,
  :pattern => "UpDown",
  :range => 4,     
  :rate => 8
}

arpeggiator = Diamond::Arpeggiator.new(options) 
```

Create a clock object, passing in a tempo value. In this case the tempo will be 138 BPM

```ruby
clock = Diamond::Clock.new(138)
```

Point the clock to the arpeggiator

```ruby
clock << arpeggiator
```

Of course, an arpeggiator needs notes to work with. You can use a MIDI input for that. ([see example](http://github.com/arirusso/diamond/blob/master/examples/midi_note_input.rb)). However, again for the sake of simplicity here's a chord in Ruby

```ruby
chord = ["C3", "G3", "Bb3", "A4"]
```

Use `Arpeggiator#add` and `Arpeggiator#remove` to change the notes that the arpeggiator sees. (`Arpeggiator#<<` is the same as add)  

```ruby
arpeggiator.add(chord)   
arpeggiator << "C5"
```

Now we'll start the clock and arpeggiator.  

Note that by default, the clock will run in a background thread. If you're working in a [PRY](http://pryrepl.org)/[IRB](http://en.wikipedia.org/wiki/Interactive_Ruby_Shell)/etc this will allow you to continue to code while the arpeggiator runs. To start in the *foreground*, pass `:focus => true` to `Clock#start`.

```ruby
clock.start
```

All of the [arpeggiator options](http://rubydoc.info/github/arirusso/diamond/master/Diamond/Arpeggiator:initialize) can be controlled on the on the fly

```ruby
arpeggiator.rate = 16
arpeggiator.gate = 20  
arpeggiator.remove("C5", "A4")
```

[This screencast video](http://vimeo.com/25983971) shows Diamond being live coded in this way.  (Note that the API has changed a bit since 2011 when the video was made).

This [blog post](http://tx81z.blogspot.com/2011/07/live-coding-with-diamond.html) explains what is happening in the video.

####Posts

* [Introduction](http://tx81z.blogspot.com/2011/07/diamond-midi-arpeggiator-in-ruby.html)
* [Live coding Diamond and syncing multiple arpeggiators to each other](http://tx81z.blogspot.com/2011/07/live-coding-with-diamond.html)
* [A note about live coding in IRB with OSX](http://tx81z.blogspot.com/2011/09/note-about-live-coding-in-irb-with-osx.html)

####Examples

* [Control via OSC](http://github.com/arirusso/diamond/blob/master/examples/osc_control.rb)
* [Define a Pattern](http://github.com/arirusso/diamond/blob/master/examples/define_pattern.rb)
* [Feed notes to Diamond using a MIDI controller or other input](http://github.com/arirusso/diamond/blob/master/examples/midi_note_input.rb)
* [Feed notes to Diamond using MIDI message objects](http://github.com/arirusso/diamond/blob/master/examples/midi_message_objects.rb)
* [Sync multiple Arpeggiator instances to each other](http://github.com/arirusso/diamond/blob/master/examples/sync_multiple_arps.rb)
* [Sync Diamond to external MIDI clock](http://github.com/arirusso/diamond/blob/master/examples/midi_clock_sync.rb)
* [Use Diamond as a master MIDI clock](http://github.com/arirusso/diamond/blob/master/examples/midi_clock_output.rb)

[More...](http://github.com/arirusso/diamond/blob/master/examples)
 
##Other Documentation

* [rdoc](http://rubydoc.info/github/arirusso/diamond)

##Author

* [Ari Russo](http://github.com/arirusso) <ari.russo at gmail.com>

##License

Apache 2.0, See the file LICENSE

Copyright (c) 2011-2014 Ari Russo