require "./languages/Brainfucklike.rb"

class Brainfuck < Brainfucklike
	def initialize(options)
		super
	
		# Check options for brainfuck specific flags
		@zero_tape = options.include?("-0") or options.include?("--zero-tape")
		@embed_input = options.include?("-i") or options.include?("--embed-input")
	end
	
	def preprocess_program
		# Call super to handle embedded input
		super
		
		# Only keep the language characters, discard everything else from program
		@program.gsub!(/[^+-\.,<>\[\]]/,'')
	end
end
