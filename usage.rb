print <<EOF
Esoteric programming language interpreter.

Usage:

./esoint.rb [options] [file]
ruby esoint.rb [options] [file]

Language is detected from file extension:
   .bf       Brainfuck
   .bfk      Brainfork
   .blub     Blub
   .cow      COW
   .ook      Ook!
   .spoon    Spoon

You can force languages with the following options:
   --blub --brainfork --brainfuck --cow --ook --spoon

Language specific options:
   -0 --zero-tape     Brainfuck pointer can't go under zero.
   -i --embed-input   Input data comes from end of program, delimited by '!'
EOF
