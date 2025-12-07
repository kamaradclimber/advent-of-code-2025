#!/usr/bin/env ruby

require 'set'

grid = File.read('input.txt').lines.map(&:chars)

beams = grid.size.times.map { Set.new }

beams.first << grid.first.index('S')

splits = 0
(grid.size-1).times do |level|
  beams[level-1].each do |idx|
    case grid[level][idx]
    when '^'
      splits += 1
      beams[level] << idx-1
      beams[level] << idx+1
    when '.'
      beams[level] << idx
    else
      raise "Unknown char #{grid[level][idx]}"
    end
  end
end

puts "Part1: #{splits}"

# part2: he who can do the most, can do the least!
timelines = (grid.size-1).times.map { [0] * grid.first.size }
timelines << [1] * grid.first.size
# bottom lines have a single timeline leading to them (and there is no splitter on the bottom line)
(0..grid.size-2).to_a.reverse.each do |level|
  grid[level].size.times do |idx|
    case grid[level][idx]
    when '.'
      timelines[level][idx] = timelines[level+1][idx]
    when '^'
      timelines[level][idx] = timelines[level+1][idx-1] + timelines[level+1][idx+1]
    when 'S'
      puts "Part2: #{timelines[1][idx]}"
    end
  end
end
