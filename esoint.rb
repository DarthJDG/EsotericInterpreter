#!/usr/bin/ruby

# If we're called without any parameters, show help
if ARGV[0] == nil
	require "./usage.rb"
	abort
end

filename = ARGV.pop  # Filename should be the last parameter
language = ""        # We don't know the language yet

# If the last parameter is an option, show help
if filename =~ /^-/ then
	require "./usage.rb"
	abort
end

# Match file extensions to determine language

if filename =~ /\.b$/ or filename =~ /\.bf$/ then; language = "Brainfuck"
elsif filename =~ /\.ook$/ then; language = "Ook"
elsif filename =~ /\.blub$/ then; language = "Blub"
elsif filename =~ /\.cow$/ then; language = "Cow"
elsif filename =~ /\.spoon$/ then; language = "Spoon"
end

# Check options for forced languages

ARGV.each {|arg|
	case arg
		when "--brainfuck"; language = "Brainfuck"
		when "--ook";       language = "Ook"
		when "--blub";      language = "Blub"
		when "--cow";       language = "Cow"
		when "--spoon";     language = "Spoon"
	end
}

# If language is unknown, abort
if language.empty? then
	abort("Unknown language.")
end

# Check if file exists
unless File.exists?(filename) then
	abort("File not found.")
end

# Read the program to pass through to interpreter
program = File.read(filename)

# Instantiate the desired interpreter and run the program
# The interpreter's filename must be the same as the class name!

require "./languages/#{language}.rb"
Object.const_get(language).new(ARGV).run(program)
