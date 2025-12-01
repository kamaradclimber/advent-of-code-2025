#!/usr/bin/env ruby
# frozen_string_literal: true

res = File.read('input1.txt').split("\n").each_with_object([50, 0, 0]) do |instruction, memo|
  # memo is: current position, number of stops on 0, number of times dial pointed to 0
  c = instruction.chars
  dir = c.first
  others = c.drop 1

  count = others.join.to_i
  before = memo[0]
  if dir == 'L'
    memo[0] -= count
  else
    memo[0] += count
  end
  memo[2] += (memo[0].abs / 100)
  # also count crossing the 0 from the right to the left
  memo[2] += 1 if before.positive? && memo[0].negative?
  # also count stopping on zero (when coming from the right)
  memo[2] += 1 if memo[0].zero?
  memo[0] %= 100
  memo[1] += 1 if memo[0].zero?
end
puts res[1]
puts res[2]
