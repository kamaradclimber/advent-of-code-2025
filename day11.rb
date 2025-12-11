#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'

GRAPH = File.read('input.txt').split("\n").map do |line|
  input, outputs = line.split(':')
  [input, Set.new(outputs.strip.split(' '))]
end.to_h

def count_paths_to(device, paths_to_device)
  paths_to_device[device] ||= GRAPH
                              .select { |_, outs| outs.include?(device) }
                              .map { |input, _| count_paths_to(input, paths_to_device) }
                              .sum
end

part1 = count_paths_to('out', { 'you' => 1 })
puts "Part1: #{part1}"

from_svr_to_dac = count_paths_to('dac', { 'svr' => 1 })
from_dac_to_fft = count_paths_to('fft', { 'dac' => 1 })
from_fft_to_out = count_paths_to('out', { 'fft' => 1 })

from_svr_to_fft = count_paths_to('fft', { 'svr' => 1 })
from_fft_to_dac = count_paths_to('dac', { 'fft' => 1 })
from_dac_to_out = count_paths_to('out', { 'dac' => 1 })

part2 = from_svr_to_dac * from_dac_to_fft * from_fft_to_out + from_svr_to_fft * from_fft_to_dac * from_dac_to_out

puts "Part2: #{part2}"
