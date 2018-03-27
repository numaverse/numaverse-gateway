class BlocksController < ApplicationController
  def index
    @blocks = Block.order('number desc').page(params[:page])
  end

  def show
    @block = Block.find(params[:id])
  end
end
