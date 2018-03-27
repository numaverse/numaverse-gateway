class AuthenticationController < ApplicationController
  def login
  end

  def sign
    address = Networker.validate_signature(params[:signature])    
    if params[:address] == address
      @account = Account.make_by_address(address)
      session[:account_id] = @account.id
      render partial: 'accounts/show.json.jbuilder', locals: { account: @account }
    else
      render json: { status: 403, message: "Signature doesn't match address." }
    end
  end

  def logout
    session[:account_id] = nil
    redirect_to login_path, notice: "You've been logged out successfully."
  end
end
