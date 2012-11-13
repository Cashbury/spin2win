require 'ostruct'

class SetupController < ApplicationController

  def new
    @n = OpenStruct.new
    @m = OpenStruct.new
    @l = OpenStruct.new
  end 

end
