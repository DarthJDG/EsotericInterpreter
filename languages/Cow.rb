require "./languages/Brainfucklike.rb"

class Cow < Brainfucklike
	def initialize(options)
		super
		
		# Check options for COW specific flags
		@zero_tape = options.include?("-0") or options.include?("--zero-tape")
		
		@max_value = nil   # Values are not limited in the spec, use full int range
	end
	
	def preprocess_program
		# Only keep COW instructions, discard everything else from program
		@program = @program.scan(/moo|mOo|moO|mOO|Moo|MOo|MoO|MOO|OOO|MMM|OOM|oom/)
	end
	
	def do_instruction(instruction)
		# COW instruction set
		case instruction
			when "moo";   end_loop
			when "mOo";   pointer_sub
			when "moO";   pointer_add
			when "mOO";   value_exec
			when "Moo";   get_or_put_char
			when "MOo";   value_sub
			when "MoO";   value_add
			when "MOO";   start_loop
			when "OOO";   value_zero
			when "MMM";   register_toggle
			when "OOM";   put_int
			when "oom";   get_int
		end
	end
	
	def value_exec
		# Execute instruction depending on current value
		case self.current_item
			when 0;    end_loop
			when 1;    pointer_sub
			when 2;    pointer_add
			when 4;    get_or_put_char
			when 5;    value_sub
			when 6;    value_add
			when 7;    start_loop
			when 8;    value_zero
			when 9;    register_toggle
			when 10;   put_int
			when 11;   get_int
		end
	end
	
	def start_loop
		# Custom COW loop ignores an instruction when jumping
		# Doesn't use loop stack
	
		if self.value == 0
			# Skip next instruction
			@ip += 1
		
			# Jump to next matching end_loop
			depth = 1
			begin
				@ip += 1
				case @program[@ip]
					when "MOO";   depth += 1
					when "moo";   depth -= 1
					when nil;     break
				end
			end until depth == 0
		end
	end

	def end_loop
		# Custom COW loop ignores an instruction when jumping
		# Doesn't use loop stack
	
		if self.value != 0
			# Skip previous instruction
			@ip -= 1
		
			# Jump to next matching end_loop
			depth = 1
			begin
				abort("No matching start_loop.") if @ip < 1
				@ip -= 1
				case @program[@ip]
					when "MOO";   depth -= 1
					when "moo";   depth += 1
					when nil;     break
				end
			end until depth == 0
		end
	end
end
