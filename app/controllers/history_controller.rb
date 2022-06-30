class HistoryController < ApplicationController
  def index
    @users = User.all
    @categories = Category.all.to_h {|category|
      users = User.all.to_h {|user|

        # Points for day for user for category
        all_day = user.points.where("category_id = :id and created_at >= :time", {id: category.id, time: Time.now.beginning_of_week})

        # Split out negative and positive
        day = {
          neg: all_day.where("value < 0").sum(:value).abs,
          pos: all_day.where("value > 0").sum(:value),
        }

        # Create a hash of user point breakdowns
        [user, day]
      }
      [category, users]
    }
  end
end
