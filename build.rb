require './config'
require 'ostruct'
require 'securerandom'
require 'pp'

class Build

  # can I do these variable declarations with an attribute?
  @@virtual_stops = 32**3 # [32, 64, 72, 128, 256], industry standards. this is total, cube for per reel.
  def self.virtual_stops
    @@virtual_stops
  end
  def virtual_stops # instance variable
    @virtual_stops = @@virtual_stops
  end

  @@virtual_reel = OpenStruct.new
  @@virtual_reel.range = 0..(virtual_stops - 1) # to align with RNG
  def self.virtual_reel
    @@virtual_reel
  end
  def virtual_reel # should just need instance variable for virtual reel, it will not be accessed by simulation
    @virtual_reel = @@virtual_reel
  end

  # access pay line table probability, map to virtual reel. build loser line table, equal probabilities to reach 1.0.
  # This is the access to payline tables
  n = ConfigSlot.n
  m = ConfigSlot.m
  l = ConfigSlot.l
  
  # 1), 2) Map each payline to a virtual reel range, 4) generate pay tab for :nm and :nml tokens, can just remove l pay range
  # will be overlap between different tokens, DRY
  nml = OpenStruct.new
  nm = OpenStruct.new
  # multiply all probabilities from all pay lines for total win percentage
  nml.win_probability =  n.payline.values.inject(:+) + m.payline.values.inject(:+) + l.payline.values.inject(:+) 
  nm.win_probability =  n.payline.values.inject(:+) + m.payline.values.inject(:+)

  # Upper bound of range from zero
  nml.win_upper_bound = virtual_stops * nml.win_probability - 1 
  nm.win_upper_bound  = virtual_stops * nm.win_probability - 1 # -1 to account for RNG beginning from 0

  virtual_reel.win = Hash.new
  virtual_reel.win[:nml] = 0..nml.win_upper_bound # win condition, remember different token conditions
  virtual_reel.win[:nm] = 0..nm.win_upper_bound
  def win(random_number, token)
    if virtual_reel.win[token] === random_number # range contains integer
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
    virtual_reel.random = SecureRandom.random_number(virtual_reel.range.max) 
    if (token == :nml)
      win(virtual_reel.random, :nml)
    elsif (token == :nm)
      win(virtual_reel.random, :nm)  
    end
  end
  
end
