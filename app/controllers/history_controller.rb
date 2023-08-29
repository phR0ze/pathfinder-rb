class HistoryController < ApplicationController
  def index
    @users = User.all

    # Default is to have the week start on Monday
    start = (params[:prior].nil? || params[:prior] == 0) ? Time.now.beginning_of_week : Time.now.beginning_of_week - 1.week
    finish = start + 1.week - 1.day
    @range = start.strftime("%m/%d") + " - " + finish.strftime("%m/%d")

    # Points per week per user per category
    @categories = Category.all.to_h {|category|
      user_signed_points = User.all.to_h {|user|
        points = user.points.where("category_id = :id and created_at >= :time", {id: category.id, time: start})

        # Split out negative and positive
        signed_points = {
          neg: points.where("value < 0").sum(:value).abs,
          pos: points.where("value > 0").sum(:value),
        }

        # Create a hash of signed points per category breakdowns
        [user, signed_points]
      }
      [category, user_signed_points]
    }

    # Total points per week per user
    @weekly = User.all.to_h {|user|
      points = user.points.where("created_at >= :time", {time: start}).sum(:value)
      [user, points]
    }

  end
end
