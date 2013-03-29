require "./modules/os.rb"

# Utility class to handle inputs. It supports input streams and tty as well.
# To avoid infinite loops and/or crashes, the program terminates if trying
# to read from the stream after EOF.

if OS.windows?
	require "Win32API"
	$win32_console_getch = Win32API.new("msvcrt", "_getch", [], "I")
end

module Utils
	def Utils.getc
		ch = nil
	
		if $stdin.tty?
			# If input is coming from tty, use OS functions to get a char
			if OS.windows?
				ch = $win32_console_getch.call
			else
				begin
					system("stty raw -echo")
					ch = STDIN.getc.ord
				ensure
					system("stty -raw echo")
				end
			end
		else
			# If input is coming from stream, read a char
			ch = $stdin.getc.ord
			abort if ch == nil   # End of input reached, end program
		end
		
		abort("Ctrl-C pressed.") if ch == 3   # Ctrl-C is pressed, end program
		
		# Change char 13 to char 10
		ch = 10 if ch == 13
		
		return ch.chr
	end
	
	def Utils.gets
		str = $stdin.gets
		abort if str == nil   # End of input reached, end program
	end
end
