class UsersController < ApplicationController
  def index
    @users = User.all.to_h {|user|

      # Get all points for the given user for the day
      all_points = user.points.where("created_at >= ?", Time.now.beginning_of_day)

      # Sort out all the negative and positive points separately and
      # track any new points for the given user
      points = {
        neg: all_points.where("value < 0").sum(:value).abs,
        pos: all_points.where("value > 0").sum(:value),
        new: all_points.where("created_at >= ?", 10.seconds.ago(Time.now)).sum(:value)
      }

      # Create a user hash of user properties
      [user, points]
    }
  end
end
