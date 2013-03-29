require "./languages/Brainfucklike.rb"

class Blub < Brainfucklike
	def initialize(options)
		super
		
		# Check options for Blub specific variables
		@zero_tape = options.include?("-0") or options.include?("--zero-tape")
	end
	
	def preprocess_program
		# Get rid of all whitespace characters and split instructions
		@program.gsub!(/[\s]/,"")
		@program.downcase!
		@program = @program.scan(/.{1,10}/)
	end

	def do_instruction(instruction)
		# Blub instruction set
		case instruction
			when "blub.blub?";   pointer_add
			when "blub?blub.";   pointer_sub
			when "blub.blub.";   value_add
			when "blub!blub!";   value_sub
			when "blub!blub.";   put_char
			when "blub.blub!";   get_char
			when "blub!blub?";   start_loop("blub?blub!")
			when "blub?blub!";   end_loop
		end
	end
end