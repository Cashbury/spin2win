require 'benchmark'
require './build' # need virtual stops per reel from this class and the play method
require 'ostruct'

class Simulate

  time = Benchmark.realtime do # assume single processor and use realtime, n processors at 100% = realtime/n

  game_build = Build.new
  game_cycle = OpenStruct.new

  # 1) set the number of spins with statistical significance in mind
  # Sample size n: n = 10*d with d = input dimensions
  game_cycle.sample_size = (game_build.virtual_stops) * 10 
  puts "Number of simulation iterations for statistical significance: #{game_cycle.sample_size}"
  puts

  # 2) Generate the spin credit distribution, input from config/setup file
  # From configuration file, take percentage of nml credits and multiply by game_cycle.sample_size
  # Define spin credit distribution. Fixed for testing purposes. Just NML dist, just NM dist, etc. can be configured.
  game_cycle.nml = game_cycle.sample_size# / 2
  game_cycle.nm = 0 #game_cycle.sample_size / 2 

  # can differentiate more between nml and nm tokens, need to develop statistics concurrently at this point.
  # what variables will need to be stored for statistical analysis? 
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

  # 3) Output the simulation result feed and analysis (tbd)
  output = File.new('output.html', 'w')
  output.puts "<p>Total number of wins: #{wins}</p>"
  output.puts "<p>Total number of losses: #{losses}</p>"
  output.puts "<p>Win probability is #{wins / Float(game_cycle.sample_size)}</p>"
  output.puts "<p>Loss probability is #{losses / Float(game_cycle.sample_size)}</p>"

  # simulation.report
  # play feed, variance analysis, total cost to business, number of prizes granted
  # for each prize from the business:
  # number of prizes won by customers for a total cost of $
  # etc. see lexicon
  p game_build.win_count

  end

  puts "#{time} seconds elapsed."
end
