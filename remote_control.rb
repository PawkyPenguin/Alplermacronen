#! /usr/bin/env ruby

require './config'

def try_parser(parser, method_name, value)
	if parser.respond_to?(method_name)
		arity = parser.method(method_name).arity
		if arity == 0
			parser.send(method_name)
			return true
		elsif arity == 1
			parser.send(method_name, value)
			return true
		end
	end
	return false
end

def try_primary_parser(parser, method_name)
	if parser.respond_to?(method_name) && parser.method(method_name).arity == 0
		parser.send(method_name)
		return true
	end
	return false
end


grab = true
if ARGV.size != 1
	abort("ERROR: Expected exactly one argument.\n
	      Usage: ./remote_control.rb /dev/input/eventX")
end

# Check if evtest is installed
`evtest --version`
if $? != 0
	abort("Could not found the `evtest` command. Try adjusting your path variable. If typing `evtest --version` in your shell executes a valid command, I screwed up (please file a bug report ;) ).")
end

device = ARGV[0]
if !File.exists?(device)
	abort("ERROR: Device file does not exist")
end

# For now, grab is always true, but later I might implement a flag for setting it
if grab
	cmd = "sudo evtest --grab '#{device}'"
else
	cmd = "sudo evtest '#{device}'"
end

puts "Executing the following command: #{cmd}"
puts "Are you sure? (Type YES to confirm)"
confirmation = STDIN.gets.chomp
if confirmation != "YES"
	abort("Aborted.")
end

parser = Parser.new
press_parser = PressParser.new
hold_parser = HoldParser.new
release_parser = ReleaseParser.new

# get sudo permissions
`sudo echo`
IO.popen(cmd) do |process|
	while(1)
		line = process.gets
		if line.start_with?("Event: ") && line.match?(/\(EV_KEY\)/)
			# Received a key event, so parse it.
			event = line.split(", ").map{|e| e.split(" ")}
			key_code = event[2][1]
			key_event = event[2][2].tr("()", "")

			# A value of 1 signifies key "press", 0 is "release", 2 is "hold"
			value = event[3][1].to_i
			case value
			when 0
				primary_parser = release_parser
			when 1
				primary_parser = press_parser
			when 2
				primary_parser = hold_parser
			end

			# just try parsers in sequence, till once succeeds
			try_primary_parser(primary_parser, key_event) \
				|| try_primary_parser(primary_parser, "code_#{key_code}") \
				|| try_parser(parser, key_event, value) \
				|| try_parser(parser, "code_#{key_code}", value)
		end
	end
end

