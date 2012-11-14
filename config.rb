require 'pp' # pretty print
require 'ostruct'

# Input from this file will be received from view, sent to controller, and then to this file.

class ConfigSlot
  
  n = OpenStruct.new
  m = OpenStruct.new
  l = OpenStruct.new
  
  # 1) Define the maximum number of prizes for each prize category
  n.prize_total = 2
  m.prize_total = 2
  l.prize_total = 2

  # 2) Set the symbols needed to run the game
  # symbol count = prize total + 1 
  
  # 3) Define the paylines 
  n.payline_prob = [0.03, 0.02] 
  m.payline_prob = [0.04, 0.05]
  l.payline_prob = [0.06, 0.07]

  n.payline = Hash.new
  m.payline = Hash.new
  l.payline = Hash.new

  n.symbols = Array.new
  m.symbols = Array.new
  l.symbols = Array.new

  #n.payline[:n1] = [ probability: 0.03, symbol: 'i' ] # this is how I want the data structured in the controller

  # get away from these loops and into MVC format, should accept input from form.
  for i in 1..n.prize_total
    n.payline[:"n#{i}"] = n.payline_prob[i-1] 
    n.symbols.push :"n#{i}" 
  end
  for i in 1..m.prize_total
    m.payline[:"m#{i}"] = m.payline_prob[i-1]
    m.symbols.push :"m#{i}"
  end
  for i in 1..l.prize_total
    l.payline[:"l#{i}"] = l.payline_prob[i-1] 
    l.symbols.push :"l#{i}"
  end

  # 4) Define the prizes, how do I make a general hash with these specific keys and they will be 
  #    filled in from the form?
  n.prize = Hash.new
  m.prize = Hash.new
  l.prize = Hash.new
  n.prize[:n1] = [ business_name: 'foo', prize_value: 1, prize_cost: 1,
                      prize_group: 'n', max_spend: 1, max_quantity: 1 ]


  # 5) Assign or auto-assign the prize to an available payline in the group
  # from form in View, assign prize to payline :n1, etc.

  # 6) coin distribution definition, use percentages, see new info
  token = OpenStruct.new
  token.nml_percentage = 1.0
  token.nm_percentage  = 0.0
  
  # Class variables
  @@n = n
  def self.n 
    @@n
  end
  @@m = m
  def self.m 
    @@m
  end
  @@l = l
  def self.l 
    @@l
  end
end
