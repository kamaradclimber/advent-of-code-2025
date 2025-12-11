#!/usr/bin/env ruby

machines = File.read('input.txt').split("\n").map do |line|
  if line =~ /\[([\.#]+)\] ((\([0-9,]+\) )+){(.+)}/
    ts_string = $1
    transitions_string = $2
    joltage_target_string = $4
    target_state = $1.tr('.', '0').tr('#', '1').to_i(2)
    transitions = transitions_string.split(" ").map do |group|
      group.gsub(/[\(\)]/,'').split(",").map { |s| 2**(ts_string.size - s.to_i-1) }.sum
    end
    transitions_bis = transitions_string.split(" ").map do |group|
      group.gsub(/[\(\)]/,'').split(",").map(&:to_i)
    end
    joltage_target = joltage_target_string.split(',').map(&:to_i)
    [target_state, transitions, joltage_target, transitions_bis]
  end
end

part1 = machines.map do |machine|
  # store the state as a key and the number of transitions to get there as a value
  paths = {0 => [[], 0]}
  to_explore = [0]

  while to_explore.any?
    state = to_explore.shift
    machine[1].each do |transition|
      new_state = state ^ transition
      new_cost = paths[state][1] + 1
      paths.include?(new_state)
      to_explore << new_state unless paths.include?(new_state)
      if !paths[new_state] || paths[new_state][1] > new_cost
        p = paths[state][0] + [transition]
        paths[new_state] = [p,new_cost]
      end
    end
  end
  # puts "Target: #{machine[0]}"
  # puts "Path: " + paths[machine[0]][0].map(&:to_s).join(";")
  # puts "Cost: #{paths[machine[0]][1]}"
  paths[machine[0]][1]
end.sum

puts "Part1: #{part1}"

def below?(a, b)
  raise "Size mismatch between #{a} and #{b}" if a.size != b.size
  a.zip(b).all? { |aa,bb| aa <= bb }

end

def build_new_state(state, transition)
  new_state = state.dup
  transition.each do |button|
    new_state[button] += 1
  end
  new_state
end

require 'algorithms'

module Astar
  
  def self.run(start, goal, heuristic = nil)
    closed = []
    open = Containers::PriorityQueue.new
    openSet = []
    open.push(start, 0)
    openSet << start

    begin
      currentNode = open.pop
      return if currentNode == goal

      currentNode.edges.each do |edge|
        successor = currentNode.follow(edge)
        next if closed.include? successor

        g_score = currentNode.g_score + edge.weight
        next if openSet.include?(successor) && g_score >= successor.g_score
        successor.predecessor = currentNode
        successor.g_score = g_score

        f_score = g_score
        if heuristic
          f_score += heuristic.call(currentNode, successor)
        end
        unless openSet.include? successor
          open.push(successor, -f_score)
          openSet << successor
        end

      end

      closed << currentNode
    end until open.empty?
  end
end


class Node
  attr :value
  def initialize(value, transitions, nodes_by_state)
    @value = value
    @transitions = transitions
    @nodes_by_state = nodes_by_state
    @g_score = 0
  end

  def ==(other)
    @value == other.value
  end

  def hash
    @value.hash
  end

  def edges
    @transitions.map { |t| Edge.new(t) }
  end

  def follow(edge)
    s = build_new_state(@value, edge.transition)
    @nodes_by_state[s] ||= Node.new(s, @transitions, @nodes_by_state)
  end

  attr_accessor :predecessor, :g_score
end

class Edge
  def initialize(transition)
    @transition = transition
  end
  attr :transition

  def weight
    1
  end
end



part2 = machines.map do |machine|
  # [target_state, transitions, joltage_target, transitions_bis]
  puts "Target state: #{machine[0]}"
  puts "Transitions: #{machine[1]}"
  puts "Joltage target: #{machine[2]}"
  puts "Transitions bis: #{machine[3]}"
  initial_state = [0] * machine[2].size
  # store the state as a key and the number of transitions to get there as a value
  paths = {initial_state => [[], 0]}
  to_explore = [initial_state]
  max_cost = machine[2].sum
  min_cost = machine[2].max
  puts "Cost should within [#{min_cost}-#{max_cost}]"

  nodes_by_state = {}
  start = Node.new(initial_state, machine[3], nodes_by_state)
  goal = Node.new(machine[2], machine[3], nodes_by_state)
  nodes_by_state[initial_state] = start
  nodes_by_state[machine[2]] = goal

  def heuristic(currentNode, successor)
    return 0 if currentNode.g_score > max_cost
    return 0 if successor.g_score > max_cost

    return currentNode.gscore + 2
  end

  Astar.run(start, goal, &:heuristic)
  goal.g_score


  # while to_explore.any?
  #   state = to_explore.shift
  #   machine[3].each do |transition|
  #     new_state = build_new_state(state, transition)
  #     new_cost = paths[state][1] + 1
  #     paths.include?(new_state)
  #     if !paths.include?(new_state) && below?(new_state, machine[2]) && new_state != machine[2]
  #       to_explore << new_state
  #     end
  #     if !paths[new_state] || paths[new_state][1] > new_cost
  #       p = paths[state][0] + [transition]
  #       paths[new_state] = [p,new_cost]
  #     end
  #     if new_state == machine[2]
  #       puts "We reached the target, and this is the shortest path"
  #       to_explore = []
  #       break
  #     end
  #   end
  # end
  # # puts "Target: #{machine[0]}"
  # # puts "Path: " + paths[machine[0]][0].map(&:to_s).join(";")
  # # puts "Cost: #{paths[machine[0]][1]}"
  # paths[machine[2]][1] 
end.sum

puts "Part2: NOT FOUND #{part2}"
