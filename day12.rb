#!/usr/bin/env ruby
# frozen_string_literal: true

# structure
#
class Shape
  def initialize(chars)
    @chars = chars
  end

  def size
    @chars.map { |line| line.select { |c| c == '#' }.size }.sum
  end

  def rotate
    @rotate ||= Shape.new(@chars.transpose.map(&:reverse))
  end

  def flipx
    @flipx ||= Shape.new(@chars.map(&:reverse))
  end

  def flipy
    @flipy ||= Shape.new(@chars.reverse)
  end

  def transpose
    @transpose ||= Shape.new(@chars.transpose)
  end

  def all
    @all = [
      self,
      rotate,
      rotate.rotate,
      rotate.rotate.rotate,
      flipx,
      flipy,
      transpose,
      flipx.flipy.transpose
    ]
  end

  def lines
    @lines ||= @chars.each_with_index.map do |line, _x|
      a2i(line)
    end
  end
end

def a2i(array)
  array.reverse.each_with_index.map do |char, pow|
    char == '#' ? 2**pow : 0
  end.sum
end

class Grid
  def initialize(sizex, g)
    @sizex = sizex
    @sizey = g.size
    @grid = g
  end

  def self.default(sizex, sizey)
    Grid.new(sizex, sizey.times.map { 0 })
  end

  def place?(x, y, shape)
    extract = @grid[x...x + 3]
    return false if extract.size < 3
    return false if (@sizey - y - 3).negative?

    (0..2).all? do |idx|
      s = shape.lines[idx] << @sizey - y - 3
      (extract[idx] & s).zero?
    end
  end

  def place(x, y, shape)
    # we suppose place? has been called and returned true
    pre = @grid[0...x]
    post = @grid[x + 3..]
    extract = @grid[x...x + 3]

    mid = (0..2).map do |idx|
      s = shape.lines[idx] << @sizey - y - 3
      extract[idx] ^ s
    end
    new_grid = pre + mid + post
    Grid.new(@sizex, new_grid)
  end

  def hash
    @grid.hash
  end
end

# first lets read
input = File.read('input.txt')

shapes = input.split("\n\n").take_while { |block| block !~ /^\d+x\d+:/ }.map do |block|
  index = Regexp.last_match(1).to_i if block.split("\n").first =~ /(\d+):/
  shape = block.split("\n").drop(1).map(&:chars)
  [index, Shape.new(shape).all]
end.to_h

part1 = input.split("\n\n").drop_while { |block| block !~ /^\d+x\d+:/ }.first.split("\n").select do |line|
  raise 'parsing error' unless line =~ /(\d+)x(\d+): (.+)/

  puts line
  size_x = Regexp.last_match(1).to_i
  size_y = Regexp.last_match(2).to_i
  expected_quantities = Regexp.last_match(3).split(' ').map(&:to_i)

  # puts Grid.default(size_x,size_y).place?(0,0, shapes[0][0])
  # puts Grid.default(size_x,size_y).place?(1,1, shapes[0][0])
  # puts Grid.default(size_x,size_y).place?(2,2, shapes[0][0])

  # filter obvious cases first
  expected_objects = expected_quantities.sum
  minimal_placable_objects = (size_x / 3) * (size_y / 3)
  if minimal_placable_objects >= expected_objects
    puts 'There are simply enough 3x3 square to fit all gifts without doing much efforts'
    next true
  end
  required_size = expected_quantities.each_with_index.map do |quantity, idx|
    quantity * shapes[idx].first.size
  end.sum
  grid_size = size_x * size_y
  if grid_size < required_size
    puts 'There is simply not enough room in this grid to fit all gifts'
    next false
  end

  # my input does not have any of this 🙈 (the example input does but could be bruteforced)
  raise NotImplementedError
end.size

puts "Part1 #{part1}"
