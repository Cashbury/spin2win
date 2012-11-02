require 'pp' # pretty print
require 'ostruct'

class ConfigSlot
  
  n = OpenStruct.new
  m = OpenStruct.new
  l = OpenStruct.new

  n.prizes = 2
  m.prizes = 2
  l.prizes = 2

  n.payline_prob = [0.03, 0.02] # length is equivalent to n.prizes, config by user, dynamic
  m.payline_prob = [0.04, 0.05]
  l.payline_prob = [0.06, 0.07]

  n.payline = Hash.new
  m.payline = Hash.new
  l.payline = Hash.new

  n.symbols = Array.new
  m.symbols = Array.new
  l.symbols = Array.new

  # loop through so proper number of pay lines and symbols get set
  for i in 1..n.prizes
    n.payline[:"n#{i}"] = n.payline_prob[i-1] 
    n.symbols.push :"n#{i}"
  end
  for i in 1..m.prizes
    m.payline[:"m#{i}"] = m.payline_prob[i-1]
    m.symbols.push :"m#{i}"
  end
  for i in 1..l.prizes
    l.payline[:"l#{i}"] = l.payline_prob[i-1] 
    l.symbols.push :"l#{i}"
  end

  # symbol storage testing, dont forget about the ubiquitous *space*
  symbols_total = (n.symbols.length + m.symbols.length + l.symbols.length) + 1 
  p "Total number of symbols: #{symbols_total}"
 
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
