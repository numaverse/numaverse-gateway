class AccountsController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :load_account, except: [:settings, :update_settings]

  def show
    @messages = @account.messages.visible.order('created_at desc').page(params[:page])
    respond_to do |format|
      format.html { }
      format.json { render 'show', locals: { account: @account }}
    end   
  end

  def update
    authorize! :manage, @account
    if @account.update(account_params)
      @account.batch!
      render partial: 'accounts/show.json.jbuilder', locals: { account: @account } 
    else
      render json: { errors: @account.errors.full_messages }, status: :error
    end
  end

  def edit
    authorize! :manage, @account
  end

  def settings
    @account = current_account
  end

  def update_settings
    @account = current_account
    @account.update(params.require(:account).permit(:email))
    redirect_to settings_accounts_path, notice: "Your settings have been updated successfully."
  end

  private

  def account_params
    params.require(:account).permit(:username, :display_name, :bio, :location, :avatar_ipfs_hash, :email)
  end

  def load_account
    id = params[:id]
    if id.starts_with?('0x')
      @account = Account.make_by_address(id)
    else
      @account = Account.find_by(id: id) || Account.find_by(username: id)
    end
    if @account.blank?
      raise ActiveRecord::RecordNotFound.new("Couldn't find account with id: #{id}")
    end
  end

end
