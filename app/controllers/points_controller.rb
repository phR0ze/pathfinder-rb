class PointsController < ApplicationController
  def index
    @user = User.find(params[:user_id])
  end

  def new
    @user = User.find(params[:user_id])
    @categories = Category.all
  end

  def create
    @user = User.find(params[:user_id])
    success = true
    fields = params[:point]
    fields.each do |category_id, value|
      point = Point.new(value: value, user_id: @user.id, category_id: category_id)
      success = false if !point.save
    end
    if success
      redirect_to users_url
    else 
      render :new
    end
  end
end
