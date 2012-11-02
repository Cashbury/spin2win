require 'benchmark'
time = Benchmark.realtime do # assume single processor and use realtime, n processors at 100% = realtime/n

require './build' # need virtual stops per reel from this module
require 'ostruct'

game_build = Build.new
game_cycle = OpenStruct.new

# Sample size n: n = 10*d with d = input dimensions
game_cycle.sample_size = (game_build.virtual_stops) * 10 
puts "Number of simulation iterations for statistical significance: #{game_cycle.sample_size}"
puts

# Define spin credit distribution. Fixed for testing purposes. Just NML dist, just NM dist, etc. can be configured.
game_cycle.nml = game_cycle.sample_size# / 2
game_cycle.nm = 0 #game_cycle.sample_size / 2 

# can differentiate more between nml and nm tokens, need to develop statistics concurrently at this point.
wins = 0
losses = 0
game_cycle.nml.times do#game_cycle.nml.times do
  
  if (game_build.play(:nml) == :win)
    wins += 1
  else
    losses += 1
  end
end

game_cycle.nm.times do #game_cycle.nm.times do
  if (game_build.play(:nm) == :win)
    wins += 1 
  else
    losses += 1
  end
end

# Output the simulation result feed and analysis (tbd)
puts "Total number of wins: #{wins}"
puts "Total number of losses: #{losses}"
puts "Win probability is #{wins / Float(game_cycle.sample_size)}"
puts "Loss probability is #{losses / Float(game_cycle.sample_size)}"

# simulation.report

end

puts "#{time} seconds elapsed."
