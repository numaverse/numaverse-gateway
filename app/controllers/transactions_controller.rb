class TransactionsController < ApplicationController
  def index
    @transactions = Transaction.by_block_number.page(params[:page])
  end

  def show
    @transaction = Transaction.find(params[:id])
  end
end
