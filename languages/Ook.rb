require "./languages/Brainfucklike.rb"

class Ook < Brainfucklike
	def initialize(options)
		super
		
		# Check options for Ook! specific variables
		@zero_tape = options.include?("-0") or options.include?("--zero-tape")
	end
	
	def preprocess_program
		# Get rid of all whitespace characters and split instructions
		@program.gsub!(/[\s]/,"")
		@program.downcase!
		@program = @program.scan(/.{1,8}/)
	end
	
	def do_instruction(instruction)
		# Ook! instruction set
		case instruction
			when "ook.ook?";   pointer_add
			when "ook?ook.";   pointer_sub
			when "ook.ook.";   value_add
			when "ook!ook!";   value_sub
			when "ook!ook.";   put_char
			when "ook.ook!";   get_char
			when "ook!ook?";   start_loop("ook?ook!")
			when "ook?ook!";   end_loop
		end
	end
end