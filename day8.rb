#!/usr/bin/env ruby
# frozen_string_literal: true

class Box
  attr_accessor :circuit
  attr_reader :x, :y, :z

  def initialize(line)
    @x, @y, @z = line.split(',').map(&:to_i)
  end

  def d(other)
    (x - other.x)**2 + (y - other.y)**2 + (z - other.z)**2
  end

  def distance(other)
    Math.sqrt(d(other))
  end

  def to_s
    "#{x},#{y},#{z}"
  end
end

require 'set'

class Circuit
  attr_reader :points

  def initialize(p)
    @points = Set.new([p])
  end

  def merge!(other)
    other.points.each do |p|
      points << p
      p.circuit = self
    end
  end
end

points = File.read('input.txt').split("\n").map { |line| Box.new(line) }
points.each { |p| p.circuit = Circuit.new(p) }

distances = []
max_connections = if points.size == 20
                    # example input
                    10
                  else
                    1000
                  end

points.each_with_index do |p, i|
  points.drop(i + 1).each do |p2|
    d = p.d(p2)
    distances << [p, p2, d]
  end
end
distances = distances.sort_by(&:last)

def debug_circuits(points)
  puts points.map(&:circuit).uniq.group_by do |c|
    c.points.size
  end.map { |size, cs| "#{cs.size} circuits of size #{size}" }.join(', ')
end

connections_done = 0
loop do
  raise 'not enough stored distances' if distances.empty?

  p, p2, = distances.shift
  if !p.circuit.points.include?(p2)
    p.circuit.merge!(p2.circuit)
    # puts "Merging circuit of #{p} with circuit of #{p2}, size of the network is #{p.circuit.points.size}"
    # print "-> "
    # debug_circuits(points)
  else
    # puts "circuits of #{p} and #{p2} are already connected"
  end
  connections_done += 1
  circuits = points.map(&:circuit).uniq
  if connections_done == max_connections
    circuits = points.map(&:circuit).uniq
    # puts "There are #{circuits.size} circuits now"
    largest_circuits = circuits.sort_by { |c| c.points.size }.last(3)
    product = largest_circuits.map { |c| c.points.size }.reduce(&:*)
    puts "Part1: #{product}"
  end
  if circuits.size == 1
    puts "Part2: #{p.x * p2.x}"
    break
  end
end
