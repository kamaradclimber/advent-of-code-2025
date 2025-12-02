#!/usr/bin/env ruby


ranges = ARGV.shift.chomp.split(',').map do |s|
  s.split("-").map(&:to_i)
end

def is_invalid(id)
  return false if id.to_s.size.odd?

  chars = id.to_s.chars
  cut = chars.size / 2
  chars[0...cut] == chars[cut..]
end

def is_invalid2(id)
  id.to_s =~ /^(\d+)(\1)+$/
end

def is_invalid2bis(id) # without regexp, slower
  chars = id.to_s.chars
  (1..chars.size/2).any? do |size|
    next if chars.size % size != 0

    chars.each_slice(size).uniq.size == 1
  end
end


invalid_ids_part1 = ranges.map do |range|
  (range[0]..range[1]).to_a.select { |id| is_invalid(id) }.sum
end

puts invalid_ids_part1.sum

invalid_ids_part2 = ranges.map do |range|
  (range[0]..range[1]).to_a.select { |id| is_invalid2(id) }.sum
end

puts invalid_ids_part2.sum

invalid_ids_part2bis = ranges.map do |range|
  (range[0]..range[1]).to_a.select { |id| is_invalid2bis(id) }.sum
end

puts invalid_ids_part2bis.sum
