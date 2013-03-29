require "./languages/Brainfucklike.rb"

class Spoon < Brainfucklike
	def initialize(options)
		super
		
		# Check options for Ook! specific variables
		@zero_tape = options.include?("-0") or options.include?("--zero-tape")
	end
	
	def preprocess_program
		# Keep only the language characters
		@program.gsub!(/[^01]/,"")
		
		# Split instructions
		@program = @program.scan(/1|000|010|011|0011|00100|001010|0010110|00101110|00101111/)
	end
	
	def do_instruction(instruction)
		# Spoon instruction set
		case instruction
			when "1";          value_add
			when "000";        value_sub
			when "010";        pointer_add
			when "011";        pointer_sub
			when "0011";       end_loop
			when "00100";      start_loop("0011")
			when "001010";     put_char
			when "0010110";    get_char
			when "00101110";   print_tape
			when "00101111";   abort
		end
	end
end