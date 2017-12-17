class HoldParser
	def KEY_LEFT
		puts "Holding key Left"
	end

	def KEY_UP
		puts "Holding key Up"
	end
end

class PressParser
	def KEY_UP
		puts "Pressed key Up"
	end
end

class ReleaseParser
	def KEY_DOWN
		puts "Released key Down"
	end
end

class Parser
	def KEY_UP
		# This method only gets executed when the Up key is released. This is
		# because it already exists in `HoldParser` and in `PressParser`, but not
		# in `ReleaseParser`
		puts "An event for key Up arrived! It was a release!"
	end

	def KEY_RIGHT(value)
		puts "An event for key Right arrived! Parsing event..."

		# Disambiguate over the possible values
		case(value)
		when 0
			puts "\tIt was released."
		when 1
			puts "\tIt was pressed."
		when 2
			puts "\tIt was held."
		end
	end
end
