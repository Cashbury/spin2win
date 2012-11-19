require './config'
require 'ostruct'
require 'securerandom'
require 'pp'

class Build < ConfigSlot

  @@virtual_stops = 32**3 # [32, 64, 72, 128, 256], industry standards. this is total, cube for per reel.
  def self.virtual_stops
    @@virtual_stops
  end

  def virtual_stops # accesible for simulate class
    @virtual_stops = @@virtual_stops
  end
  
  @@virtual_reel = OpenStruct.new
  @@virtual_reel.range = 0..(virtual_stops - 1) # to align with RNG

  # length of probability range on virtual reel
  n.payline_length = Hash.new
  m.payline_length = Hash.new
  l.payline_length = Hash.new
  n.payline_prob.each_key { |key, value| n.payline_length[key] = Integer(virtual_stops * n.payline_prob[key]) }
  m.payline_prob.each_key { |key, value| m.payline_length[key] = Integer(virtual_stops * m.payline_prob[key]) }
  l.payline_prob.each_key { |key, value| l.payline_length[key] = Integer(virtual_stops * l.payline_prob[key]) }



  # winning virtual reel map
  @@n.virtual_reel_win_map = Hash.new
  @@m.virtual_reel_win_map = Hash.new
  @@l.virtual_reel_win_map = Hash.new
  start = 0
  n.payline_length.each_key { 
    |key| 
    @@n.virtual_reel_win_map[key] = start..(start + n.payline_length[key]-1)
    start = start + n.payline_length[key]
 }
  m.payline_length.each_key { 
    |key| 
    @@m.virtual_reel_win_map[key] = start..(start + m.payline_length[key]-1)
    start = start + m.payline_length[key]
  }
  l.payline_length.each_key { 
    |key| 
    @@l.virtual_reel_win_map[key] = start..(start + l.payline_length[key]-1)
    start = start + l.payline_length[key]
  }
  # generate all symbol combinations, even probability for all losing combinations, 
  loseline = OpenStruct.new
  loseline.probability_total = 1 - (@@n.payline_prob_array.inject(:+) + @@m.payline_prob_array.inject(:+) + @@l.payline_prob_array.inject(:+)) 
  #puts "loseline probability: #{loseline.probability_total}"
  loseline.total_number_of = @@symbol.keys.length ** 3 - @@n.prize_total - @@m.prize_total - @@l.prize_total
  #puts "total number of loselines: #{loseline.total_number_of}"
  loseline.individual_probability = loseline.probability_total / Float(loseline.total_number_of)
  #puts "individual probability for each loseline: #{loseline.individual_probability}"
  loseline.reel_length_individual = Integer(virtual_stops * loseline.individual_probability)
  #puts loseline.reel_length_individual
  @@virtual_reel_lose_map = Hash.new
  def self.virtual_reel_lose_map
    @@virtual_reel_lose_map
  end
  for i in 1..loseline.total_number_of
    if i != loseline.total_number_of # need to extend last loseline to end of range
      @@virtual_reel_lose_map[:"lose#{i}"] = start..(start + loseline.reel_length_individual - 1)
      start = start + loseline.reel_length_individual
    else 
      @@virtual_reel_lose_map[:"lose#{i}"] = start..(@@virtual_reel.range.max)
    end
  end

#### Virtual reel output
  def output_virtual_reel
    output = File.new('virtual_reel.html', 'w')
    output.puts "<p> Whole range: #{@@virtual_reel.range} </p>"
    @@n.virtual_reel_win_map.each { |key, value| output.puts "<p> Range for #{key}: #{value} </p>" }
    @@m.virtual_reel_win_map.each { |key, value| output.puts "<p> Range for #{key}: #{value} </p>" }
    @@l.virtual_reel_win_map.each { |key, value| output.puts "<p> Range for #{key}: #{value} </p>" }
    @@virtual_reel_lose_map.each  { |key, value| output.puts "<p> Range for #{key}: #{value} </p>" }
    output.close
  end

### Interface reel output 
  def output_interface_reel
    output = File.new('interface_reel.html', 'w')
    output.puts "<p> Each reel is the same, they look like following: <p>"
    output.print "<p>"
    @@symbol.each { |key, value| unless(key==:s1)
                                  output.print " #{value} #{@@symbol[:s1]}" 
                                 end }
    output.puts "</p>"
  end

  def win?(random_number, token)
    if    token == :n
      if (n_check(random_number) == :win)
        return :win
      else
        #loss_check
        return :loss
      end
    elsif token == :nm
      if(n_check(random_number) == :win)
        return :win
      elsif(m_check(random_number) == :win)
        return :win
      else
        return :loss
      end
    elsif token == :nml
      if(n_check(random_number) == :win)
        return :win
      elsif(m_check(random_number) == :win)
        return :win
      elsif(l_check(random_number) == :win)
        return:win
      else
        #lose_check
        return :loss
      end
    end
  end

  # keep track of individual payline wins
  @@n.wins = Hash.new(0)
  @@m.wins = Hash.new(0)
  @@l.wins = Hash.new(0)


  def n_payline_theoretical(payline_key)
    @@n.payline_prob[payline_key]
  end
  def m_payline_theoretical(payline_key)
    @@m.payline_prob[payline_key]
  end
  def l_payline_theoretical(payline_key)
    @@l.payline_prob[payline_key]
  end

## The following methods check paylines for a win
  @@wins = 0
  def n_check(random_number)
    @@n.virtual_reel_win_map.each {
      |key, value|
      if @@n.virtual_reel_win_map[key] === random_number
        #p "win with #{key} #{random_number} #{value}"
        #@@wins = @@wins + 1
        @@n.wins[key] = @@n.wins[key] + 1
        #puts "Prize #{key} won: #{@@n.prize[key]}"
        return :win
      end
    }
  end
  def m_check(random_number)
    @@m.virtual_reel_win_map.each {
      |key, value|
      if @@m.virtual_reel_win_map[key] === random_number
        #p "win with #{key}"
        #@@wins = @@wins + 1
        @@m.wins[key] = @@m.wins[key] + 1 
        #puts "Prize #{key} won: #{@@m.prize[key]}"
        return :win
      end
    }
  end
  def l_check(random_number)
    @@l.virtual_reel_win_map.each {
      |key, value|
      if @@l.virtual_reel_win_map[key] === random_number
        #p "win with #{key}"
        #@@wins = @@wins + 1
        @@l.wins[key] = @@l.wins[key] + 1 
        #puts "Prize #{key} won: #{@@l.prize[key]}"
        return :win
      end
    }
  end
###

  def n_payline_wins
     @@n.wins
  end
  def m_payline_wins
     @@m.wins
  end
  def l_payline_wins
     @@l.wins
  end

  def win_count_total 
     @@wins
  end

  def user
    @@user
  end
  def credit
    @@credit
  end

  def reset
    @@n.wins = Hash.new(0)
    @@m.wins = Hash.new(0)
    @@l.wins = Hash.new(0)
  end

=begin
  def prize_check
  end
=end

  def play(token)
    random_number = SecureRandom.random_number(@@virtual_reel.range.max) 
    if (token == :nml)
      win?(random_number, :nml)
    elsif (token == :nm)
      win?(random_number, :nm)  
    elsif (token == :n)
      win?(random_number, :n)
    end
  end
  
end
