require 'pp' # pretty print
require 'ostruct'

# Input from this file will be received from view, sent to controller, and then to this file.

class ConfigSlot
  # Class variables
  @@n = OpenStruct.new
  def self.n 
    @@n
  end
  @@m = OpenStruct.new
  def self.m 
    @@m
  end
  @@l = OpenStruct.new
  def self.l 
    @@l
  end

  # 1) Define the maximum number of prizes for each prize category
  n.prize_total = 2
  m.prize_total = 2
  l.prize_total = 2

  # 2) Set the symbols needed to run the game
  # symbol_count = prize total + 1 
  
  # 3) Define the paylines
  n.payline_prob_array = [0.03, 0.02] 
  m.payline_prob_array = [0.04, 0.05]
  l.payline_prob_array = [0.06, 0.07]

  n.payline_prob = Hash.new
  m.payline_prob = Hash.new
  l.payline_prob = Hash.new

  n.symbols = Array.new
  m.symbols = Array.new
  l.symbols = Array.new

  # 2,3
  for i in 1..n.prize_total
    n.payline_prob[:"n#{i}"] = n.payline_prob_array[i-1]
    n.symbols.push :"n#{i}" 
  end
  for i in 1..m.prize_total
    m.payline_prob[:"m#{i}"] = m.payline_prob_array[i-1]
    m.symbols.push :"m#{i}"
  end
  for i in 1..l.prize_total
    l.payline_prob[:"l#{i}"] = l.payline_prob_array[i-1] 
    l.symbols.push :"l#{i}"
  end

  # 4) Define the prizes, how do I make a general hash with these specific keys and they will be 
  #    filled in from the form?
  n.prize = Hash.new
  m.prize = Hash.new
  l.prize = Hash.new
  n.prize[:n1] = [ business_name: 'foo', prize_value: 1, prize_cost: 1,
                      prize_group: 'n', max_spend: 1, max_quantity: 1 ]
  # add a few more generics

  # 5) Assign or auto-assign the prize to an available payline in the group
  # from form in View, assign prize to payline :n1, etc.

  # 6) coin distribution and user definition, use percentages, see new info
  user = OpenStruct.new
  user.count = 100
  user.credit_distribution = Hash.new
  for i in 1..user.count
    user.credit_distribution[:"u#{i}"] = [ n: 0.2, nm: 0.6, nml: 0.2 ]
  end

  credit = OpenStruct.new
  credit.rate_per_day = 1000

=begin
  token = OpenStruct.new
  token.nml_percentage = 1.0
  token.nm_percentage  = 0.0
=end 
  end
