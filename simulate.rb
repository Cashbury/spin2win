require 'benchmark'
require './build' # need virtual stops per reel from this class and the play method
require 'ostruct'

class Simulate

  time = Benchmark.realtime do # assume single processor and use realtime, n processors at 100% = realtime/n

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
  game_build = Build.new
  game_cycle.days = game_build.credit.total / game_build.credit.rate_per_day  # this implies a total of 400,000 credits issued. For statistical significance, this 10 day game cycle will need logged and computed upon n times.
  #for each user use their credits to play the game and keep track of wins/losses/prizes and then rank the users
  #also use this information to tally business cost, etc.
  iterations = 1
  wins = 0
  losses = 0
  game_cycle.wins = Hash.new
  game_cycle.losses = Hash.new
  game_cycle.n_payline_wins = Hash.new
  game_cycle.m_payline_wins = Hash.new
  game_cycle.l_payline_wins = Hash.new
  for i in 1..iterations
    game_cycle.wins[:"gc#{i}"] = 0
    game_cycle.losses[:"gc#{i}"] = 0
    for j in 1..game_cycle.days
      game_build.user.n_credits.each { |user, value|
        for k in 1..value 
          if (game_build.play(:n, user) == :win)
            game_cycle.wins[:"gc#{i}"] += 1
          else
            game_cycle.losses[:"gc#{i}"]+=1
          end
        end
      }

      game_build.user.nm_credits.each { |user, value| 
        for k in 1..value 
          if (game_build.play(:nm, user) == :win)
            game_cycle.wins[:"gc#{i}"] += 1
          else
            game_cycle.losses[:"gc#{i}"]+= 1
          end
        end
      }
                                      
      game_build.user.nml_credits.each { |user, value| 
        for k in 1..value 
          if (game_build.play(:nml, user) == :win)
            game_cycle.wins[:"gc#{i}"]+=1
          else
            game_cycle.losses[:"gc#{i}"] +=1
          end
        end
      }
    end
    # do some statistics during iteration, payline probability, game cycle, etc.
    game_cycle.n_payline_wins[:"gc#{i}"] = game_build.n_payline_wins
    game_cycle.m_payline_wins[:"gc#{i}"] = game_build.m_payline_wins
    game_cycle.l_payline_wins[:"gc#{i}"] = game_build.l_payline_wins
    game_build.reset # resets class variables, @@user may need reset when further iterations employed
  end

  puts game_cycle.n_payline_wins
  puts game_cycle.m_payline_wins
  puts game_cycle.l_payline_wins

  puts "Total credits used in each game cycle: #{game_build.credit.rate_per_day * game_cycle.days}"

  # Output total wins and losses
  game_cycle.wins.each { |key, value| puts "Game cycle #{key} total wins: #{value}" 
                                      puts "Game cycle #{key} total losses: #{game_cycle.losses[key]}"}

  # 3) Output the simulation result feed and analysis interface and virtual reel
  # virtual reel
  game_build.output_virtual_reel
  game_build.output_interface_reel
  game_build.output_pay_table

  #Simulation result feed, need some methods for statistical computations.
  output = File.new('output.html', 'w')
  output.puts "<p> #{game_cycle.days} day game cycle played #{iterations} times.</p>"
 
  #output.puts "<p> Win average: </p>"
  #output.puts "<p> Loss average: </p>"

  output.puts "<p> N prize paylines statistics: </p>"
  game_cycle.n_payline_wins.each { |key1, value2|
    # iterates through each game_cycle, 1 for now
    game_cycle.n_payline_wins[key1].each { |key2, value2|
      output.print "<p> Variance percentage between theoretical and experimental probability for payline #{key2}: "
      output.puts  "#{(game_build.n_payline_theoretical(key2) - (value2 / Float(game_build.credit.total))) / game_build.n_payline_theoretical(key2) * 100} percent. </p>" }
    }

  output.puts "<p> M prize paylines statistics: </p>"
  game_cycle.m_payline_wins.each { |key1, value2|
    # iterates through each game_cycle, 1 for now
    game_cycle.m_payline_wins[key1].each { |key2, value2|
      output.print "<p> Variance percentage between theoretical and experimental probability for payline #{key2}: "
      output.puts  "#{(game_build.m_payline_theoretical(key2) - (value2 / Float(game_build.credit.total*(game_build.credit.distribution[:nml]+game_build.credit.distribution[:nm])))) / game_build.m_payline_theoretical(key2) * 100} percent. </p>" }
    }
  
  output.puts "<p> L prize paylines statistics (Note: the much lower probability is a result of only 20% of the credit distribution being :nml): </p>"
  game_cycle.l_payline_wins.each { |key1, value2|
    # iterates through each game_cycle, 1 for now
    game_cycle.l_payline_wins[key1].each { |key2, value2|
      output.print "<p> Variance percentage between theoretical and experimental probability for payline #{key2}: "
      output.puts  "#{(game_build.l_payline_theoretical(key2) - (value2 / Float(game_build.credit.total*game_build.credit.distribution[:nml]) )) / game_build.l_payline_theoretical(key2)* 100} percent. </p>" }
    }
 
  output.puts "<p> Business statistics: </p>"
  game_build.business.log.each_key { |key| 
                                    output.puts "<p> Business #{key}, #{game_build.business.log[key][:business_name]} </p>"
                                    output.puts "<p> Total cost: #{game_build.business.log[key][:total_cost]} </p>"
                                    output.puts "<p> Total value: #{game_build.business.log[key][:total_value]} </p>"
                                    output.puts "<p> Total value - total cost: #{game_build.business.log[key][:total_value] - game_build.business.log[key][:total_cost]} </p>"
                                    output.puts "<p> Number of users who won a prize: #{game_build.business.log[key][:user_winners].length} </p>"
                                    output.puts "<br>" 
                                    }


  output.puts "<p> User log, descending order by number of wins: </p>"
  output.puts "<p> #{game_build.user.log.sort{|a,b| b[1][:wins] <=> a[1][:wins]}} </p>"
    
  output.close
  end

  puts "#{time} seconds elapsed."
end
