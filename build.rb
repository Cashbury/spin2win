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
 
  n.win_probability = n.payline.values.inject(:+)
  m.win_probability = m.payline.values.inject(:+)
  l.win_probability = l.payline.values.inject(:+)

  win_upper_bound = Hash.new
  win_upper_bound[:nml] = virtual_stops * (n.win_probability + m.win_probability + l.win_probability) - 1
  win_upper_bound[:nm]  = virtual_stops * (n.win_probability + m.win_probability) - 1

  @@virtual_reel.win = Hash.new
  @@virtual_reel.win[:nml] = 0..win_upper_bound[:nml] # win condition, remember different token conditions
  @@virtual_reel.win[:nm] = 0..win_upper_bound[:nm]
  
  def win(random_number, token)
    if @@virtual_reel.win[token] === random_number # range contains integer
      return :win
    else
      return :lose
    end
  end

  # 3) Output the virtual and interface reel
  pp n.payline.sort_by{|key, value| value}
  pp m.payline.sort_by{|key, value| value}
  pp l.payline.sort_by{|key, value| value}
  
  def play(token)
    random_number = SecureRandom.random_number(@@virtual_reel.range.max) 
    if (token == :nml)
      win(random_number, :nml)
    elsif (token == :nm)
      win(random_number, :nm)  
    end
  end
  
end
