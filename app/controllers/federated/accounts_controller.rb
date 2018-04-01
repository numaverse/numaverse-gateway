class Federated::AccountsController < ApplicationController
  before_action :load_account, except: [:search]
  # before_action :authenticate_user!

  rescue_from Goldfinger::NotFoundError, with: :redirect_home
  rescue_from ActiveRecord::RecordNotFound, with: :redirect_home

  def search
    parts = params[:handle].split('@')
    host = parts.last
    local_host = Addressable::URI.parse(Rails.application.routes.url_helpers.root_url).host
    if local_host == host
      account = Account.find_by!(username: parts[1])
      redirect_to account_path(account)
    else
      data = Goldfinger.finger(params[:handle].gsub(/^@/, 'acct:'))
      ap_url = data.link('self')&.href
      puts ap_url
      @account = Federated::Account.from_remote_id(ap_url)
      redirect_to federated_account_path(@account)
    end
  end

  def show
    if current_account
      @follow = Federated::Follow.find_by(
        from_account: current_account.federated_account,
        to_account: @account
      )
    end
  end

  private

  def load_account
    @account = Federated::Account.find(params[:id])
  end

  def redirect_home
    redirect_to root_path, alert: "Sorry, we couldn't find that user."
  end
end
