#!/usr/bin/env ruby
# frozen_string_literal: true

banks = File.read('input.txt').split("\n").map(&:chars)

def max_joltage(battery)
  battery = battery.map(&:to_i)
  digit_value = battery[0...battery.size - 1].max
  digit_index = battery.index(digit_value)
  second_digit = battery[digit_index + 1..].max
  digit_value * 10 + second_digit
end

# this one is also solving part1 if nbbatt is set to 2
def max_joltage_part2(battery, nbbatt)
  index_left = 0
  index_right = battery.size - (nbbatt - 1)
  joltage = 0
  battery = battery.map(&:to_i)
  nbbatt.times do
    digit_value = battery[index_left...index_right].max
    digit_index = index_left + battery[index_left...index_right].index(digit_value)
    joltage = joltage * 10 + digit_value
    index_left = digit_index + 1
    index_right += 1
  end
  joltage
end

# part1
puts banks.map { |bank| max_joltage(bank) }.sum
puts banks.map { |bank| max_joltage_part2(bank, 2) }.sum
# part2
puts banks.map { |bank| max_joltage_part2(bank, 12) }.sum
