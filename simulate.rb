require 'benchmark'
require './build' # need virtual stops per reel from this class and the play method
require 'ostruct'

class Simulate

  time = Benchmark.realtime do # assume single processor and use realtime, n processors at 100% = realtime/n

  game_build = Build.new
  game_cycle = OpenStruct.new

  # 1) set the number of spins with statistical significance in mind
  # Sample size n: n = 10*d with d = input dimensions, for use when testing payline probability
  # game_cycle.sample_size = (game_build.virtual_stops) * 10 
  #puts "Number of simulation iterations for statistical significance: #{game_cycle.sample_size}"
  #puts

  # 2) Generate the spin credit distribution, input from config/setup file
  # Define spin credit distribution. Fixed for testing purposes. 
  # Credit and User distribution now defined in configuration.
=begin
  game_cycle.nml = game_cycle.sample_size# / 2
  game_cycle.nm = 0 #game_cycle.sample_size / 2 
  game_cycle.n = 0
=end

# build statistics around this play style
  game_cycle.days = 10  # this implies a total of 100,000 credits issued. For statistical significance, this 10 day cycle will need logged and computed upon n times.
  #for each user use their credits to play the game and keep track of wins/losses/prizes and then rank the users
  #also use this information to tally business cost, etc.
  iterations = 1
  wins = 0
  losses = 0
  for i in 1..iterations
    for i in 1..game_cycle.days
      game_build.user.n_credits.each { |key, value| 
        for i in 1..value 
          if (game_build.play(:n) == :win)
            wins += 1
          else
            losses +=1
          end
        end
      }

      game_build.user.nm_credits.each { |key, value| 
        for i in 1..value 
          if (game_build.play(:nm) == :win)
            wins+=1
          else
            losses += 1
          end
        end
      }
                                      
      game_build.user.nml_credits.each { |key, value| 
        for i in 1..value 
          if (game_build.play(:nml) == :win)
            wins+=1
          else
            losses +=1
          end
        end
      }
    end
  end

  puts wins
  puts losses

  # 3) Output the simulation result feed and analysis interface and virtual reel
  # virtual reel
  game_build.output_virtual_reel
  game_build.output_interface_reel

  #Simulation result feed, need some methods for statistical computations.
  output = File.new('output.html', 'w')
  output.puts "<p> #{game_cycle.days} day game cycle played #{iterations} times.</p>"
 
  output.puts "<p> Win average: </p>"
  output.puts "<p> Loss average: </p>"

  output.puts "<p> N prize paylines statistics: </p>"
  output.puts "<p> M prize paylines statistics: </p>"
  output.puts "<p> L prize paylines statistics: </p>"

  output.puts "<p> Business statistics: </p>"
  output.puts "<p> User statistics: </p>"
    
  output.close
 
=begin
  output.puts "<p>Total number of iterations: #{game_cycle.sample_size}"
  output.puts "<p>Total number of wins: #{wins}</p>"
  output.puts"<p>Total number of losses: #{losses}</p>"
  # statistics need changed because of play method
  output.puts "<p>Win probability is #{wins / Float(game_cycle.sample_size)}</p>"
  output.puts "<p>Loss probability is #{losses / Float(game_cycle.sample_size)}</p><br>"
  
  output.puts "<p> N prize paylines' win count: #{game_build.n_payline_wins} </p>"
  game_build.n_payline_wins.each { |key, value| #output.puts "<p> Theoretical probability for payline #{key}: #{game_build.n_payline_theoretical(key)}</p>"
                                                #output.puts "<p> Experimental probability for payline #{key}: #{value / Float(game_cycle.sample_size)} </p>" 
    output.print "<p> Variance percentage between theoretical and experimental results for payline #{key}: "
    output.puts  "#{(game_build.n_payline_theoretical(key) - (value / Float(game_cycle.sample_size))) / game_build.n_payline_theoretical(key) * 100} percent. </p><br>" }

  output.puts "<p> M prize paylines' win count: #{game_build.m_payline_wins} </p>"
  game_build.m_payline_wins.each { |key, value| #output.puts "<p> Theoretical probability for payline #{key}: #{game_build.m_payline_theoretical(key)}</p>" 
                                                #output.puts "<p> Experimental probability for payline #{key}: #{value / Float(game_cycle.sample_size)} </p>"
      output.print "<p> Variance percentage between theoretical and experimental results for payline #{key}: "
      output.puts  "#{(game_build.m_payline_theoretical(key) - (value / Float(game_cycle.sample_size))) / game_build.m_payline_theoretical(key) * 100} percent. </p><br>" }

  output.puts "<p> L prize paylines' win count: #{game_build.l_payline_wins} </p>"
  game_build.l_payline_wins.each { |key, value| #output.puts "<p> Theoretical probability for payline #{key}: #{game_build.l_payline_theoretical(key)}</p>"
                                                #output.puts "<p> Experimental probability for payline #{key}: #{value / Float(game_cycle.sample_size)} </p>"
      output.print "<p> Variance percentage between theoretical and experimental results for payline #{key}: "
      output.puts  "#{(game_build.l_payline_theoretical(key) - (value / Float(game_cycle.sample_size))) / game_build.l_payline_theoretical(key) * 100} percent. </p><br>" }

  output.close
  
  game_build.win_count_total
=end
  # simulation.report
  # play feed, variance analysis, total cost to business, number of prizes granted
  # for each prize from the business:
  # number of prizes won by customers for a total cost of $
  # etc. see lexicon

  end

  puts "#{time} seconds elapsed."
end
