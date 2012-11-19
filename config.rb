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

  @@symbol = Hash.new
  def self.symbol
    @@symbol
  end

  # 1) Define the maximum number of prizes for each prize category
  n.prize_total = 2
  m.prize_total = 2
  l.prize_total = 2

  # 2) Set the symbols needed to run the game
  symbol_count = n.prize_total + m.prize_total + l.prize_total + 1 
  for i in 1..symbol_count
    symbol[:"s#{i}"] = nil # symbol assignment, e.g. '7' 
  end
  symbol[:s1] = 'space'
  # temp, this needs to be input driven
  symbol[:s2] = '7'
  symbol[:s3] = 'bar'
  symbol[:s4] = 'bell'
  symbol[:s5] = 'cherry'
  symbol[:s6] = 'star'
  symbol[:s7] = 'x'
  
  # 3) Define the paylines, probability of occuring with the proper tokens
  n.payline_prob_array = [0.03, 0.02] 
  m.payline_prob_array = [0.04, 0.05]
  l.payline_prob_array = [0.06, 0.07]

  n.payline_prob = Hash.new
  m.payline_prob = Hash.new
  l.payline_prob = Hash.new

  n.symbol = Hash.new
  m.symbol = Hash.new
  l.symbol = Hash.new

  # Setting symbols and defining paylines, triple of assigned symbol to payline is the winner
  for i in 1..n.prize_total
    n.payline_prob[:"n#{i}"] = n.payline_prob_array[i-1]
    n.symbol[:"n#{i}"] = :"s#{i+1}"  # i + 1 to skip over space
  end
  for i in 1..m.prize_total
    m.payline_prob[:"m#{i}"] = m.payline_prob_array[i-1]
    m.symbol[:"m#{i}"] = :"s#{i+1+n.prize_total}"
  end
  for i in 1..l.prize_total
    l.payline_prob[:"l#{i}"] = l.payline_prob_array[i-1] 
    l.symbol[:"l#{i}"] = :"s#{i+1+n.prize_total+m.prize_total}"
  end

  # 4) Define the prizes, how do I make a general hash with these specific keys and they will be 
  #    filled in from the form?
  n.prize = Hash.new
  m.prize = Hash.new
  l.prize = Hash.new

  # prize definitions
  for i in 1..n.prize_total
    n.prize[:"n#{i}"] = { business_id: :b1, business_name: 'cashbury', prize_name: "prize_n#{i}", prize_value: 5, prize_cost: 1,
                      prize_group: 'n', prize_type: 'item', max_spend: 1, max_quantity: 1 }
  end
  for i in 1..m.prize_total
    m.prize[:"m#{i}"] = {  business_id: :b2, business_name: 'blue bottle', prize_name: "prize_m#{i}", prize_value: 3, prize_cost: 1,
                      prize_group: 'm', prize_type: 'item', max_spend: 1, max_quantity: 1 }
  end
  for i in 1..l.prize_total
    l.prize[:"l#{i}"] = {  business_id: :b3, business_name: 'starbucks', prize_name: "prize_l#{i}", prize_value: 2, prize_cost: 1,
                      prize_group: 'l', prize_type: 'credit', max_spend: 1, max_quantity: 1 }
  end

  # business info
  @@business = OpenStruct.new
  def self.business
    @@business
  end
  business.log = Hash.new
  business.log[:b1] = { business_name: 'cashbury', prizes_issued: 0, total_value: 0, total_cost: 0, user_winners: Array.new}
  business.log[:b2] = { business_name: 'blue_bottle', prizes_issued: 0, total_value: 0, total_cost: 0, user_winners: Array.new}
  business.log[:b3] = { business_name: 'starbucks', prizes_issued: 0, total_value: 0, total_cost: 0, user_winners: Array.new}

  # 5) Assign or auto-assign the prize to an available payline in the group
  # from form in View, assign prize to payline :n1, etc.

  # 6) coin distribution and user definition, use percentages, see new info
  @@user = OpenStruct.new
  def self.user
    @@user
  end
  user.count = 100 # can change, a percentage of the user population will contain a percentage of the credits. generate distribution and users dynamically.
  user.n_credits = Hash.new
  user.nm_credits = Hash.new
  user.nml_credits = Hash.new
  user.log = Hash.new
  @@credit = OpenStruct.new
  def self.credit
    @@credit
  end
  credit.total = 400000
  credit.distribution = Hash.new
  credit.distribution[:n] = 0.2 
  credit.distribution[:nm] = 0.6
  credit.distribution[:nml] = 0.2
  credit.rate_per_day = 1000
  for i in 1..user.count
    user.n_credits[:"u#{i}"]   = credit.rate_per_day / user.count * credit.distribution[:n]
    user.nm_credits[:"u#{i}"]  = credit.rate_per_day / user.count * credit.distribution[:nm]
    user.nml_credits[:"u#{i}"] = credit.rate_per_day / user.count * credit.distribution[:nml]
    user.log[:"u#{i}"] = {wins: 0, value: 0}
  end
  


=begin
  token = OpenStruct.new
  token.nml_percentage = 1.0
  token.nm_percentage  = 0.0
=end 
  end
