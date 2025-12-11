#!/usr/bin/env ruby
# frozen_string_literal: true

coords = File.read('input.txt').split("\n").map do |line|
  line.split(',').map(&:to_i)
end

def area(p1, p2)
  ((p1[0] - p2[0]).abs + 1) * ((p1[1] - p2[1]).abs + 1)
end

part1 = coords.each_with_index.flat_map do |p1, idx|
  coords.drop(idx + 1).map do |p2|
    area(p1, p2)
  end
end.max

puts "Part1: #{part1}"

ALL_LINES = (0...coords.size).map do |idx|
  [coords[idx], coords[(idx + 1) % coords.size]]
end

def rectangle_within_shape?(p1, p2, lines)
  minx = [p1[0], p2[0]].min
  maxx = [p1[0], p2[0]].max
  miny = [p1[1], p2[1]].min
  maxy = [p1[1], p2[1]].max
  sides = [
    [[minx, miny], [maxx, miny]],
    [[maxx, miny], [maxx, maxy]],
    [[maxx, maxy], [minx, maxy]],
    [[minx, maxy], [minx, miny]]
  ]
  a = lines.all? { |line| sides.none? { |side| _intersect?(side, line) } }
  return false unless a

  b = lines.any? do |p3, p4|
    next true if strictly_within?(p3, p1, p2) && !strictly_within?(p4, p1, p2)
    next true if strictly_within?(p4, p1, p2) && !strictly_within?(p3, p1, p2)

    false
  end
  return false if b

  # super slow check: I wish I could find something smarter
  c = expand_lines(lines).any? do |p3, p4|
    next true if strictly_within?(p3, p1, p2) && !strictly_within?(p4, p1, p2)
    next true if strictly_within?(p4, p1, p2) && !strictly_within?(p3, p1, p2)

    false
  end
  !c
end

def expand_lines(lines)
  lines + lines.flat_map do |p1, p2|
    if horizontal?([p1, p2])
      minx = [p1[0], p2[0]].min
      maxx = [p1[0], p2[0]].max
      (minx...maxx).map do |x|
        [[x, p1[1]], [x + 1, p1[1]]]
      end
    else
      miny = [p1[1], p2[1]].min
      maxy = [p1[1], p2[1]].max
      (miny...maxy).map do |y|
        [
          [p1[0], y],
          [p1[0], y + 1]
        ]
      end
    end
  end
end

def strictly_within?(p, p1, p2)
  minx = [p1[0], p2[0]].min
  maxx = [p1[0], p2[0]].max
  miny = [p1[1], p2[1]].min
  maxy = [p1[1], p2[1]].max
  p[0] > minx && p[0] < maxx && p[1] > miny && p[1] < maxy
end

def horizontal?(line)
  p1, p2 = line
  p1[1] == p2[1]
end

def _intersect?(l1, l2)
  intersect?(l1, l2)
  # puts "#{l1} intersects #{l2}: #{i}"
end

def intersect?(l1, l2)
  # if lines are aligned they cannot intersect (at least in this problem)
  return false unless horizontal?(l1) ^ horizontal?(l2)

  if horizontal?(l1)
    min_y_l2 = [l2[0][1], l2[1][1]].min
    max_y_l2 = [l2[0][1], l2[1][1]].max
    min_x_l1 = [l1[0][0], l1[1][0]].min
    max_x_l1 = [l1[0][0], l1[1][0]].max
    x_l2 = l2[0][0]
    min_y_l2 < l1[0][1] && max_y_l2 > l1[0][1] &&
      x_l2 > min_x_l1 && x_l2 < max_x_l1
  else
    intersect?(l2, l1)
  end
end

# puts intersect?([[3, 0], [3, 8]], [[4, 0], [4, 5]]) # parallel lines
# puts intersect?([[3, 0], [3, 8]], [[0, 1], [4, 1]]) # crossing lines
# puts intersect?([[3, 0], [3, 8]], [[0, 10], [4, 10]]) # perpendicular, non crossing lines

best_area = 0
coords.each_with_index.each do |p1, idx|
  coords.drop(idx + 1).each do |p2|
    candidate_area = area(p1, p2)
    next if candidate_area <= best_area

    next unless rectangle_within_shape?(p1, p2, ALL_LINES)

    puts "Found a larger area between #{p1} and #{p2}: #{candidate_area}"
    best_area = candidate_area
  end
end

puts "Part2: #{best_area}"
