class RewardsController < ApplicationController
  def index
    @users = User.all
  end

  def new
    @user = User.find(params[:user_id])
    @cashed_out = @user.rewards.sum(:value)
    @remaining = @user.points.sum(:value) - @cashed_out
  end

  def create
    user_id = params[:user_id]
    value = params[:reward][:value]
    reward = Reward.new(value: value, user_id: user_id)
    if reward.save
      redirect_to user_rewards_url
    else 
      render :new
    end
  end
end
