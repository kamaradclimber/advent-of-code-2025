#!/usr/bin/env ruby

coords = File.read("input.txt").split("\n").map do |line|
  line.split(',').map(&:to_i)
end

def area(p1,p2)
  ((p1[0] - p2[0]).abs+1) * ((p1[1]-p2[1]).abs+1)
end

part1 = coords.each_with_index.flat_map do |p1,idx|
  coords.drop(idx+1).map do |p2|
    area(p1,p2)
  end
end.max

puts "Part1: #{part1}"

ALL_LINES = (0...coords.size).map do |idx|
  [coords[idx],coords[(idx+1)%coords.size]]
end

def aligned?(p1,p2,p3,p4)
  return true if p1[0] == p2[0] && p3[0] == p4[0] && p1[0] == p3[0]
  return true if p1[1] == p2[1] && p3[1] == p4[1] && p1[1] == p3[1]
  false
end

def has_inner_line2?(p1,p2)
  ALL_LINES.any? do |p3,p4|
    minx = [p1[0],p2[0]].min
    maxx = [p1[0],p2[0]].max
    miny = [p1[1],p2[1]].min
    maxy = [p1[1],p2[1]].max
    sides = [
      [[minx,miny],[maxx,miny]],
      [[maxx,miny],[maxx,maxy]],
      [[maxx,maxy],[minx,maxy]],
      [[minx,maxy],[minx,miny]]
    ]
    next true if strictly_inside?(p3, p1,p2) && !strictly_inside?(p4,p1,p2)
    next true if strictly_inside?(p4, p1,p2) && !strictly_inside?(p3,p1,p2)
    next true if inside?(p3,p1,p2) && inside?(p4,p1,p2) && sides.none? { |s| s==[p3,p4] || s==[p4,p3] }
    false
  end
end

def inside?(p3,p1,p2)
  minx = [p1[0],p2[0]].min
  maxx = [p1[0],p2[0]].max
  miny = [p1[1],p2[1]].min
  maxy = [p1[1],p2[1]].max
  p3[0] >= minx && p3[0] <= maxx && p3[1] >= miny && p3[1] <= maxy
end

def strictly_inside?(p3,p1,p2)
  minx = [p1[0],p2[0]].min
  maxx = [p1[0],p2[0]].max
  miny = [p1[1],p2[1]].min
  maxy = [p1[1],p2[1]].max
  p3[0] > minx && p3[0] < maxx && p3[1] > miny && p3[1] < maxy
end


best_area = 0
part1 = coords.each_with_index.each do |p1,idx|
  coords.drop(idx+1).each do |p2|
    candidate_area = area(p1,p2)
    next if candidate_area <= best_area

    next if has_inner_line2?(p1,p2)
    puts "Found a larger area between #{p1} and #{p2}: #{candidate_area}"
    best_area = candidate_area
  end
end
