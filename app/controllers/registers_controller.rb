class RegistersController < ApplicationController
  before_action :signed_in_staff

  def new
    @register = Register.new(event_id: params[:event_id])
    @bool = params[:positive] == "true" ? true : false
    @accounts = Account.where(positive: @bool)
    respond_to :js
  end

  def create
    @register = Register.new(register_params)
    @bool = params[:positive] == "true" ? true : false
    @accounts = Account.where(positive: @bool)
    @event = Event.find(params[:register][:event_id])
    if @register.save
      registers = Register.where(event_id: params[:register][:event_id])
      @registers_pos = registers.joins(:account).where("accounts.positive =?", true)
      @registers_neg = registers.joins(:account).where("accounts.positive =?", false)
    end
    respond_to :js
  end

  def destroy
    register = Register.find(params[:id])
    register.destroy
    redirect_to :back
  end

  private

  def register_params
    params.require(:register).permit(:event_id, :account_id, :amount)
  end


end
