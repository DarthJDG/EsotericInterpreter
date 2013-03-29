require "stringio"
require "./modules/utils.rb"
require "./modules/deep_copy.rb"

# A generic brainfuck-like engine to be used by some languages. It implements
# all common features.

class Brainfucklike
	attr_reader :program, :program_stack, :ip_stack
	attr_reader :positive_tape, :negative_tape, :tape, :p
	attr_reader :register, :loop_stack
	attr_accessor :ip

	@program         # Stores the program that's being processed
	@program_stack   # Saved program stack for procedure calls
	@ip              # Instruction pointer for the current program
	@ip_stack        # Saved instruction pointers for procedure calls
	
	@positive_tape   # The main storage tape
	@negative_tape   # Overflow tape, in case the pointer is < 0
	@tape            # Points to the currently active tape array, either + or -
	@p               # Pointer index for the tape
	
	@register        # Register to temporarily store values
	
	@loop_stack      # Stores instruction pointer values for simple nested loops
	
	def initialize(options)
		# Set default options
		@max_value = 256       # By default values wrap at 256, set to nil to disable
		@zero_tape = false     # True if pointer is not allowed to be < 0
		@embed_input = false   # True if input comes from end of code
	end
	
	def copy(from)
		# Copy current state. Can be used for forking
		@program = from.program.deep_copy
		@program_stack = from.program_stack.deep_copy
		@ip = from.ip.deep_copy
		@ip_stack = from.ip_stack.deep_copy
		@positive_tape = from.positive_tape.deep_copy
		@negative_tape = from.negative_tape.deep_copy
		
		if from.tape == from.positive_tape
			@tape = @positive_tape
		else
			@tape = @negative_tape
		end
		
		@p = from.p.deep_copy
		@register = from.register.deep_copy
		@loop_stack = from.loop_stack.deep_copy
	end
	
	def preprocess_program
		# Initial pre-processing step, e.g stripping unused characters
		# Should only modify @program
		
		# If input comes from code, split it off first before stripping chars
		if @embed_input
			program.slice!(/!(.*)$/m)
			$stdin = StringIO.new($1)
		end
	end
	
	def reset_variables
		# Set initial class variables before starting programs
		@program_stack = []
		@ip = 0
		@ip_stack = []
		
		@positive_tape = [0]
		@negative_tape = []
		@tape = @positive_tape
		@p = 0
		
		@register = nil
		
		@loop_stack = []
	end
	
	def run(program)
		# Entry point and main loop of the program
		# Should not need to override this
		@program = program
		preprocess_program
		reset_variables
		
		instruction = @program[@ip]
		while instruction != nil
			do_instruction(instruction)
			@ip += 1
			instruction = @program[@ip]
		end
	end
	
	def do_instruction(instruction)
		# Instruction set for brainfuck-like languages
		case instruction
			when "+";	value_add
			when "-";	value_sub
			when ",";	get_char
			when ".";	put_char
			when ">";	pointer_add
			when "<";	pointer_sub
			when "[";	start_loop("]")
			when "]";	end_loop
		end
	end
	
	def value
		return @tape[@p < 0 ? -@p - 1 : @p]
	end
	
	def value=(value)
		if @max_value == nil
			@tape[@p < 0 ? -@p - 1 : @p] = value
		else
			@tape[@p < 0 ? -@p - 1 : @p] = value % @max_value
		end
	end
	
	def value_add
		self.value = self.value + 1
	end
	
	def value_sub
		self.value = self.value - 1
	end
	
	def value_zero
		self.value = 0
	end
	
	def get_or_put_char
		if self.value == 0
			self.value = Utils.getc.ord
		else
			putc self.value
		end
	end

	def get_char
		self.value = Utils.getc.ord
	end
	
	def put_char
		putc self.value
	end
	
	def put_int
		print "#{self.value} "
	end
	
	def get_int
		self.value = gets.chomp.to_i
	end

	def pointer_add
		@p += 1
		@tape = @positive_tape if @p == 0
		self.value = 0 if self.value == nil
	end
	
	def pointer_sub
		@p -= 1
		@p = 0 if @p == -1 and @zero_tape
		@tape = @negative_tape if @p == -1
		self.value = 0 if self.value == nil
	end

	def start_loop(end_instruction)
		start_instruction = @program[@ip]
		if self.value == 0
			# Jump to next matching end_loop
			depth = 1
			begin
				@ip += 1
				case @program[@ip]
					when start_instruction;   depth += 1
					when end_instruction;     depth -= 1
					when nil;                 break
				end
			end until depth == 0
		else
			# Add current instruction pointer to loop stack
			@loop_stack.push(@ip)
		end
	end
	
	def end_loop
		if self.value == 0
			# Remove loop start from stack, carry on with next command
			@loop_stack.pop
		else
			# Jump back to instruction on top of stack
			@ip = @loop_stack[-1]
			abort("Stack is empty at end_loop.") if @ip == nil
		end
	end

	def register_toggle
		if @register == nil
			@register = self.value
		else
			self.value = @register
			@register = nil
		end
	end
	
	def print_tape
		@p = -(@negative_tape.length)
		put_char
		while @p < @positive_tape.length - 1
			pointer_add
			put_char
		end
	end
end
