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

  @@n.virtual_reel_map = Hash.new
  @@m.virtual_reel_map = Hash.new
  @@l.virtual_reel_map = Hash.new
  start = 0
  n.payline_length.each_key { 
    |key| 
    @@n.virtual_reel_map[key] = start..(start + n.payline_length[key]-1)
    start = start + n.payline_length[key]
    p @@n.virtual_reel_map[key]
 }
  m.payline_length.each_key { 
    |key| 
    @@m.virtual_reel_map[key] = start..(start + m.payline_length[key]-1)
    start = start + m.payline_length[key]
    p @@m.virtual_reel_map[key]
  }
  l.payline_length.each_key { 
    |key| 
    @@l.virtual_reel_map[key] = start..(start + l.payline_length[key]-1)
    start = start + l.payline_length[key]
    p @@l.virtual_reel_map[key]
  }

  def win?(random_number, token)
    if    token == :n
      n_check(random_number)
    elsif token == :nm
      n_check(random_number)
      m_check(random_number)
    elsif token == :nml
      n_check(random_number)
      m_check(random_number)
      l_check(random_number)
    end
  end

  # keep track of individual payline wins
  @@n.wins = Hash.new(0)
  @@m.wins = Hash.new(0)
  @@l.wins = Hash.new(0)



### The following methods check paylines for a win
  @@wins = 0
  def n_check(random_number)
    @@n.virtual_reel_map.each {
      |key, value|
      if @@n.virtual_reel_map[key] === random_number
        #p "win with #{key} #{random_number} #{value}"
        @@wins = @@wins + 1
        @@n.wins[key] = @@n.wins[key] + 1 
        return :win
      end
    }
  end
  def m_check(random_number)
    @@m.virtual_reel_map.each {
      |key, value|
      if @@m.virtual_reel_map[key] === random_number
        #p "win with #{key}"
        @@wins = @@wins + 1
        @@m.wins[key] = @@m.wins[key] + 1 
        return :win
      end
    }
  end
  def l_check(random_number)
    @@l.virtual_reel_map.each {
      |key, value|
      if @@l.virtual_reel_map[key] === random_number
        #p "win with #{key}"
        @@wins = @@wins + 1
        @@l.wins[key] = @@l.wins[key] + 1 
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

=begin
  def prize_check
  end
=end

  # 3) Output the virtual and interface reel
  #pp n.payline.sort_by{|key, value| value}
  #pp m.payline.sort_by{|key, value| value}
  #pp l.payline.sort_by{|key, value| value}
  
  def play(token)
    random_number = SecureRandom.random_number(@@virtual_reel.range.max) 
    if (token == :nml)
      win?(random_number, :nml)
    elsif (token == :nm)
      win?(random_number, :nm)  
    end
  end
  
end
