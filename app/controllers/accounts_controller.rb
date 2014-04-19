class AccountsController < ApplicationController
  before_action :signed_in_user
  def index
    @subtitle = ["収入科目","支出科目"]
    @accounts = Array.new(2)
    @accounts[0] = Account.where(positive: true)
    @accounts[1] = Account.where(positive: false)
  end

  def edit
    @title = "科目名変更"
    @account = Account.find(params[:id])
    @num = params[:num].to_i
    respond_to :js 
  end

  def update
    @account = Account.find(params[:id])
    if @account.update_attributes(account_params)
      redirect_to :accounts
    else
      render 'edit'
    end
  end

  def new
    @title = "会場登録"
    @num = params[:num].to_i
    if @num == 0 
      @account = Account.new(positive: true)
    else
      @account = Account.new(positive: false)
    end
    respond_to :js 
  end

  def create
    @account = Account.new(account_params)
    if @account.save
      redirect_to :accounts
    else
      render 'new'
    end
  end


  def destroy
    account = Account.find(params[:id])
    account.destroy
    redirect_to :accounts
  end

#--------
  private
#--------
  def account_params
    params.require(:account).permit(:title, :positive)
  end

end
