# Alplermacronen

Alplermacronen is a small Ruby script that reads keyboard devices listed under `/dev` and executes some action according to keypresses.

Essentially, it is a key shortcut handler for just one keyboard (as opposed to conventional keydaemons). You probably shouldn't use it as a fully-fledged keydaemon, because it's not particularly fast and doesn't support modifier keys, such as Shift (yet?).

I wrote Alplermacronen so I can easily use USB remotes to execute arbitrary actions. I have a Desktop and a Laptop at home and I usually have a mouse plugged into both of them. However, it seems I can't find my second mouse, so instead I make due by plugging a USB remote into my Desktop and using it to control mouse movements (which works reasonably well, because usually I just do some very small task on my Desktop and it would be incredibly annoying to replug my mouse just for this purpose). If you have some kind of USB presenter at home, this script will probably work for you.

You could also hook up a second keyboard to your computer and use this script to configure shortcuts that play funny memes, I don't judge.

## Usage

Make sure you have Ruby and `evtest` installed (should be available on major Linux distros), then execute

`./alplermacronen.rb /dev/input/by-id/<device>`

where `<device>` is some device that can be used as a keyboard. If you're not sure which `device` corresponds to the keyboard you want to configure, you can try `evtest /dev/input/by-id/<device>` to figure it out.

**WARNING**: You probably shouldn't use this script on your primary keyboard, because you might not be able to stop it anymore. Also, you shouldn't pass it some garbled arguments, because I do relatively no input sanitation, so there are *definitely* code execution vulnerabilities. However, Alplermacronen will warn you about the command it will execute, so you'd have to try very hard to accidentally break something. Just don't blame me if your school loses this year's student records.

## Configuration
Configuration is done in the `config.rb`. I've included a small example. The language is Ruby, but it shouldn't be hard to figure out, even if you use Ruby.

Inside the file, you can find four classes with methods inside of them. The method names *must* correspond to events as seen by `evtest`, such as `KEY_UP` for the Up arrow key. Methods defined inside `Parser` are overriden by methods inside `PressParser`, `ReleaseParser` and `HoldParser`. As you can probably tell, the latter three parsers have methods in them that are executed when a key is pressed, released or held respectively.

### Example
For moving your mouse horizontally with your arrow keys, you can do the following:

```ruby

class HoldParser
	def KEY_RIGHT
		`xdotool mousemove_relative -- 30 0`
	end

	def KEY_LEFT
		`xdotool mousemove_relative -- -30 0`
	end
end
```

Just leave the other three classes empty (but don't delete them fully!). Note that you can just use `` `cmd` `` in Ruby to execute a shell command with `sh`.
