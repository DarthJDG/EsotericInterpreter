require "./languages/Brainfucklike.rb"

class Brainfork < Brainfucklike
	attr_accessor :new_fork

	@saved_options   # Saved list of options
	@children        # List of child threads
	@new_fork        # Set true for the first iteration of the fork

	def initialize(options)
		super
		@saved_options = options
	
		# Check options for brainfuck specific flags
		@zero_tape = options.include?("-0") or options.include?("--zero-tape")
		@embed_input = options.include?("-i") or options.include?("--embed-input")
		
		@children = []
		@new_fork = false
	end
	
	def preprocess_program
		# Call super to handle embedded input
		super
		
		# Only keep the language characters, discard everything else from program
		@program.gsub!(/[^Y+-\.,<>\[\]]/,'')
	end
	
	def run(program)
		# Entry point and main loop of the program
		@program = program
		preprocess_program
		reset_variables
		
		instruction = @program[@ip]
		while instruction != nil
			do_instruction(instruction)
			@ip += 1
			instruction = @program[@ip]
			
			@children.delete_if {|child| not child.step }
		end
		
		until @children.empty?
			@children.delete_if {|child| not child.step }
		end
	end

	def step
		if @new_fork
			@new_fork = false
			return true
		end
	
		instruction = @program[@ip]
		if instruction != nil
			do_instruction(instruction)
			@ip += 1
		end
		@children.delete_if {|child| not child.step }
		
		return false if instruction == nil and @children.empty?
		return true
	end

	def do_instruction(instruction)
		# Instruction set for Brainfork
		case instruction
			when "+";	value_add
			when "-";	value_sub
			when ",";	get_char
			when ".";	put_char
			when ">";	pointer_add
			when "<";	pointer_sub
			when "[";	start_loop("]")
			when "]";	end_loop
			when "Y";   fork
		end
	end

	def fork
		child = Brainfork.new(@saved_options)
		child.copy(self)
		child.ip += 1
		value_zero
		child.pointer_add
		child.value = 1
		child.new_fork = true
		@children.push(child)
	end
end
