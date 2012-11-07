class InputsController < ApplicationController

  def new
    @input = Input.new
    @inputs = Input.find(:all)
  end

  def create
    @input = Input.new(params[:input])
    if @input.save
      redirect_to new_input_path
    end
  end
end
