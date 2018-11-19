require './brainfuck'

program = Brainfuck.new(
  """
  ++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<++++++++++
  +++++.>.+++.------.--------.>+.>.
  """
)
puts program.interpret
