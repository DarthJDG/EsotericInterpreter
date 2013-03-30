require "./modules/utils.rb"

class Befunge93
	@program       # Holds the padded befunge run-time program
	@width         # The width of the longest line in the program
	@height        # Number of lines in the program
	
	@stack         # Data stack
	@string_mode   # True if we are in string mode
	
	@x             # Instruction pointer (column)
	@y             # Instruction pointer (line)
	@direction     # Current direction of execution

	def initialize(options)
		@stack = []
		@string_mode = false
		@x = 0
		@y = 0
		@direction = Direction::RIGHT
	end
	
	def preprocess_program
		# Split lines
		@program = @program.split("\n")
		@height = @program.length
		
		# Find the longest line
		@width = 0
		@program.each {|line|
			@width = line.length if @width < line.length
		}
		
		# Pad all lines to maximum width
		@program.map! {|line| line + (" " * (@width - line.length)) }
		
		# Allocate a minimum of 80x25 space as of Befunge-93 spec
		allocate(80, 25)
	end
	
	def run(program)
		@program = program
		preprocess_program
		
		loop do
			instruction = @program[@y][@x]
			do_instruction(instruction)
			move_pointer
		end
	end
	
	def move_pointer
		case @direction
			when Direction::UP;      @y = (@y - 1) % @height
			when Direction::DOWN;    @y = (@y + 1) % @height
			when Direction::LEFT;    @x = (@x - 1) % @width
			when Direction::RIGHT;   @x = (@x + 1) % @width
		end
	end
	
	def push_stack(value)
		@stack.push(value)
	end
	
	def pop_stack
		return @stack.empty? ? 0 : @stack.pop
	end
	
	def peek_stack
		return @stack.empty? ? 0 : @stack[-1]
	end
	
	def do_instruction(instruction)
		if @string_mode
			# If we are in string mode, copy chars to stack or check for end
			if instruction == '"'
				@string_mode = false
			else
				push_stack(instruction.ord)
			end
		else
			case instruction
				when /[0-9]/;   push_stack(instruction.to_i)
				when '"';       @string_mode = true
				when ">";       @direction = Direction::RIGHT
				when "<";       @direction = Direction::LEFT
				when "^";       @direction = Direction::UP
				when "v";       @direction = Direction::DOWN
				when "?";       @direction = rand(1..4)
				when "_";       if_horizontal
				when "|";       if_vertical
				when "@";       abort
				when "~";       push_stack(Utils.getc.ord)
				when "&";       get_int
				when ".";       print pop_stack.to_s + " "
				when ",";       print pop_stack.chr
				when "#";       move_pointer
				when ":";       push_stack(peek_stack)
				when "$";       pop_stack
				when "\\";      swap_top_two
				when "`";       greater_than
				when "g";       get_command
				when "p";       put_command
				when "+";       math_add
				when "-";       math_sub
				when "*";       math_mul
				when "/";       math_div
				when "%";       math_mod
				when "!";       push_stack(pop_stack == 0 ? 1 : 0)
			end
		end
	end
	
	def if_vertical
		@direction = (pop_stack == 0) ? Direction::DOWN : Direction::UP
	end
	
	def if_horizontal
		@direction = (pop_stack == 0) ? Direction::RIGHT : Direction::LEFT
	end
	
	def get_int
		# Read integer up to the first non-numeric character
		str = ""
		begin
			ch = Utils.getc
			str += ch if ch =~ /[0-9]/
		end while ch =~ /[0-9]/
		push_stack(str.to_i)
	end
	
	def swap_top_two
		a = pop_stack
		b = pop_stack
		push_stack(a)
		push_stack(b)
	end
	
	def greater_than
		b = pop_stack
		a = pop_stack
		push_stack(a > b ? 1 : 0)
	end
	
	def get_command
		y = pop_stack
		x = pop_stack
		push_stack(@program[y % @height][x % @width].ord)
	end
	
	def put_command
		y = pop_stack
		x = pop_stack
		value = pop_stack
		@program[y % @height][x % @width] = value.chr
	end
	
	def math_add
		b = pop_stack
		a = pop_stack
		push_stack(a + b)
	end
	
	def math_sub
		b = pop_stack
		a = pop_stack
		push_stack(a - b)
	end
	
	def math_mul
		b = pop_stack
		a = pop_stack
		push_stack(a * b)
	end
	
	def math_div
		b = pop_stack
		a = pop_stack
		push_stack((a / b).floor)
	end
	
	def math_mod
		b = pop_stack
		a = pop_stack
		push_stack(a % b)
	end
	
	def allocate(new_width, new_height)
		# It will only grow the allocated space, never shrink
		
		if @width < new_width
			@program.map! {|line| line + (" " * (new_width - @width)) }
			@width = new_width
		end
		
		if @height < new_height
			@height = new_height
			begin
				@program.push(" " * @width)
			end while @program.length < @height
		end
	end
end

module Direction
	UP    = 1
	RIGHT = 2
	DOWN  = 3
	LEFT  = 4
end