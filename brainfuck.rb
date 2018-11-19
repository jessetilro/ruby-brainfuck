# https://github.com/brain-lang/brainfuck/blob/master/brainfuck.md

class Brainfuck
  def initialize(program)
    @tape = [0]
    @pc = 0
    @pointer = 0
    @program = program
    @jump_indices = {}
    @jump_reverse_indices = {}
    @output = []
  end

  def interpret
    sanitize
    parse
    step while @pc < @program.length
    @output.map(&:chr).join('')
  end

  protected

  def sanitize
    @program = @program.gsub(/[^\+\-\[\]\>\<\,\.]/, '')
  end

  def parse
    jump_if_zero_indices = []
    @program.chars.each_with_index do |c,i|
      jump_if_zero_indices << i if c == '['
      if c == ']'
        if jump_if_zero_indices.count.positive?
          @jump_indices[jump_if_zero_indices.pop] = i
        else
          raise 'Unmatched jump unless zero'
        end
      end
    end
    raise 'Unmatched jump if zero' if jump_if_zero_indices.count.positive?
    @jump_reverse_indices = @jump_indices.invert
  end

  def step
    return if @pc >= @program.length

    case @program[@pc]
    when '+'
      increment
    when '-'
      decrement
    when '>'
      move_right
    when '<'
      move_left
    when '['
      jump_if_zero
    when ']'
      jump_unless_zero
    when '.'
      write
    when ','
      read
    else
      @pc +=1
    end
  end

  def init
    @tape[@pointer] ||= 0
  end

  def wrap
    @tape[@pointer] = 0 if @tape[@pointer] > 255
    @tape[@pointer] = 255 if @tape[@pointer] < 0
  end

  def increment
    init
    @tape[@pointer] += 1
    wrap
    @pc += 1
  end

  def decrement
    init
    @tape[@pointer] -= 1
    wrap
    @pc += 1
  end

  def move_right
    @pointer += 1
    @pc += 1
  end

  def move_left
    if @pointer == 0
      @tape.unshift 0
    else
      @pointer -= 1
    end
    @pc += 1
  end

  def jump_if_zero
    if [0, nil].include?(@tape[@pointer])
      @pc = @jump_indices[@pc] + 1
    else
      @pc += 1
    end
  end

  def jump_unless_zero
    unless [0, nil].include?(@tape[@pointer])
      @pc = @jump_reverse_indices[@pc] + 1
    else
      @pc += 1
    end
  end

  def write
    init
    @output << @tape[@pointer]
    @pc += 1
  end

  def read
    init
    @tape[@pointer] = STDIN.read(1).ord
    wrap
    @pc += 1
  end
end
