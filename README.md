# pathfinder-rb
[![License: MIT](https://img.shields.io/badge/License-MIT/Apache%202.0-blue.svg)](https://opensource.org/licenses/MIT)

***Simple point tracker in Ruby on Rails***

### Quick links
* [Ruby on Rails](#ruby-on-rails)
  * [Deploy Rails on Arch Linux](#deploy-rails-on-arch-linux)
  * [Rails Application](#rails-application)
    * [Route](#route)
    * [Controller](#controller)
    * [View](#view)
    * [Model](#model)
  * [Populate Data](#populate-data)
    * [Console](#console)
    * [Validate](#validate)
  * [Users Controller](#users-controller)
    * [List Users](#list-users)
    * [Add audio](#add-audio)
  * [Points Controller](#points-controller)
    * [New Points](#new-points)
* [Contribute](#contribute)
  * [Git-Hook](#git-hook)
* [License](#license)
  * [Contribution](#contribution)
* [Backlog](#backlog)
* [Changelog](#changelog)

---

# Ruby on Rails <a name="ruby-on-rails"/></a>
Rails is a web application framework running on the Ruby programming language. It is designed to make
programming web applications easier by making assumptions about what every developer needs to get
started. It allows you to write less code while accomplishing more. If you learn ***The Rails Way***
the sales pitch is you'll be productive. ***The Rails Way*** is based heavily on convention and is
highly opinionated.

References:
* [Ruby Documentation](https://www.ruby-lang.org/en/documentation/)
* [Getting Started with Ruby on Rails](https://guides.rubyonrails.org/getting_started.html)

## Deploy Rails on Arch Linux <a name="deploy-rails-on-arch-linux"/></a>
* [Getting Started with Ruby on Rails](https://guides.rubyonrails.org/getting_started.html)

1. Install the prerequisites:
   ```bash
   $ sudo pacman -S ruby sqlite nodejs yarn clang make pkg-config sqlitebrowser
   ```
2. Install Rails:
   ```bash
   $ gem install rails
   $ gem update
   ```
3. Add the ruby bin path to $PATH
   ```bash
   $ PATH=PATH:$HOME/.local/share/gem/ruby/3.0.0/bin
   $ rails --version
   Rails 6.1.4
   ```
4. Create a new rails application `~/Projects/pathfinder`:
   ```bash
   $ git config --global init.defaultBranch main

   # Creates a new git repo at the given name
   $ rails new pathfinder
   ```
5. Start your new web application
   ```bash
   $ cd pathfinder
   $ bin/rails server -b 0.0.0.0
   ```
6. Navigate in a browser to `http://127.0.0.1:3000`

## Rails Application <a name="rails-application"/></a>
The Rails Way makes extensive use of the `MVC (Model View Controller)` pattern. Routes, controllers,
actions, models and views are all typical pieces.  MVC is a design pattern that divides the
responsibilities of an application to make it easier to reason about.

* `route` maps a request to a controller action
* `controller` controller provides grouping for actions
* `action` functions on the controller that perform the actual work
* `model` keeps data together separate from the other components
* `view` displays the data in a desired format

In this case we'll be building a simple application that allows a user to add students, define
categories and assign a positive or negative amount of points in a category to a given student and
have the ability to see the aggregate points for the day, previous day or all time.

### Route <a name="route"/></a>
Routes are rules written in a [Ruby DSL(Domain Specific Language)](https://guides.rubyonrails.org/routing.html). 

Add our new routes to `config/routes.rb`
```ruby
Rails.application.routes.draw do
  get "/users", to: "users#index"
  get "/points", to: "points#index"
  get "/rewards", to: "rewards#index"
  get "/categories", to: "categories#index"
end
```

### Controller <a name="controller"/></a>
Controllers are Ruby classes and their public methods are actions.

Generate a few controllers we'll need:
```bash
$ bin/rails generate controller Users index --skip-routes
$ bin/rails generate controller Points index --skip-routes
$ bin/rails generate controller Rewards index --skip-routes
$ bin/rails generate controller Categories index --skip-routes
```

Rails creates a few files per controler e.g.:
* `app/controllers/users_controller.rb` the controller file
  ```ruby
  class UsersController < ApplicationController
    def index
    end
  end
  ```
* `app/views/users/index.html.rb` the view file

### View <a name="view"/></a>
Views are templates, usually written in a mixture of HTML and Ruby

Update the index file with our hello message:
```bash
$ echo "<h1>Hello Rails</h1>" > app/views/users/index.html.rb
```

### Model <a name="model"/></a>
A `model` is a Ruby class that is used to represent data. Additionally models can interact with the
appliation's database through a feature of Rails called `Active Record`.

* Use a `singular` naming convention normally because it represents a single record

* This will create a table for the given model with the given field names and type pairs `title:string`
  * `:string`       stores string type 1 to 255 characters (default = 255)
  * `:text`         stores string type 1 to 4294967296 characters (default = 65536)
  * `:datetime`     stores both date and time
  * `:timestamp`    stores both date and time
  * `:time`         stores only (hours, minutes, seconds)
  * `:date`         stores only (year, month, day)
  * `:primary_key`     
  * `:integer`      stores whole numbers 
  * `:float`        stores decimal numbers
  * `:decimal`      stores higher precision decimal numbers
  * `:binary`       stores binary data 
  * `:boolean`      stores true/false
  * `:references`   stores reference to another table    

Rails will automatically adds an `id` column for each table as an auto-incrementing primary key.
Additionally Rails will include `created_at` and `updated_at` columns and manage these for us setting
the values when we create or update a model object.

1. Create the models we'll need for our app:
   ```bash
   $ bin/rails generate model User name:string
   $ bin/rails generate model Category name:string value:integer
   $ bin/rails generate model Point value:integer user:references category:references
   ```

2. Run the resulting migrations to create the proper tables:
   ```bash
   $ bin/rails db:migrate
   ```

## Populate Data <a name="populate-data"/></a>

### Console <a name="console"/></a>
The first thin we have to do is fix rail'ss irb issue
1. Edit `Gemfile`
2. Find the the block below
   ```ruby
   group :development, :test do
     # Call 'byebug' anywhere in the code to stop execution and get a debugger console
     gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
   end
   ```
3. Add the line `gem 'irb', require: false` after `bybug`
   ```ruby
   group :development, :test do
     # Call 'byebug' anywhere in the code to stop execution and get a debugger console
     gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
     gem 'irb', require: false
   end
   ```
4. Launch the console:
   ```bash
   $ bin/rails console
   ```
5. Create a new user and save it to the database. Once the user is saved the user object gets updated
   with the finalized properties. Observable with `sqlitebrowser db/development.sqlite3`
   ```ruby
   $ user = User.new(name: "foo")
   $ user.save
   ```
6. You can use the console to do various user related operations:
   ```ruby
   # Find the specific user
   $ User.find(1)

   # List all users
   $ User.all

   # Delete the specific user
   $ User.delete(1)

   # Print out the model schema
   $ User
   ```

## Users Controller <a name="users-controller"/></a>

### List Users <a name="list-users"/></a>
Ruby global varibles are available in the view code so we can extract the users from the database
into a global variable and make them available to the view

1. Edit `app/controllers/users_controller.rb` and add the db lookup for all users.
   ```ruby
   class UsersController < ApplicationController
     def index
       @users = User.all
     end
   end
   ```
2. Now edit `app/views/users/index.html.erb` and add some templating to list them out. The `<%=`
   means evaluate the ruby then output the result.
   ```
   <h1>Users</h1>
   
   <ul>
     <% @users.each do |user| %>
       <li>
         <%= user.name %>
       </li>
     <% end %>
   </ul>
   ```

### Add audio <a name="add-audio"/></a>
To add a sound clip we can play when given a user points we need to:

1. Add the new sound to `app/assets/audios`
2. Add `//= link_tree ../audios` to `app/assets/config/manifest.js`
3. Restart the server `bin/rails server -b 0.0.0.0`

## Points Controller <a name="points-controller"/></a>
Rails has a helper called `resources` that maps all CRUD operations for an endpoint to the
controller. We can edit `config/routes.rb` and replace our points entry with `resources :points` to
get all CRUD operations mapped to our points controller.

```ruby
Rails.application.routes.draw do
  resources :points
end
```

### New Points <a name="new-points"/></a>
1. Edit the points controller `app/controllers/points_controller.rb` and add the following functions.
   The `new` function is used to create a new instance but not save it and the `create` to save out a
   fully populated instance.
   ```ruby
   def new
     @point = Point.new
   end
   def create
     @points = Points.new(value: 1, category_id: 1, user_id: 1)
     if @points.save
       # Use redirect_to after mutating the database so that if the page is refreshed it doesn't
       # repeat the same request
       redirect_to @users
     else
       render :new
     end
   end
   ```
2. Using the Rails Form Builder to create the form edit `app/views/points/new`
   ```
   ```

### Validate <a name="validate"/></a>
1. Start the rails app back up
   ```bash
   $ bin/rails server
   ```
2. Navigate in a browser to `http://127.0.0.1:3000/users`


---

# Contribute <a name="Contribute"/></a>
Pull requests are always welcome. However understand that they will be evaluated purely on whether
or not the change fits with my goals/ideals for the project.

## Git-Hook <a name="git-hook"/></a>
Enable the git hooks to have automatic version increments
```bash
cd ~/Projects/clu
git config core.hooksPath .githooks
```

# License <a name="license"/></a>
This project is licensed under either of:
 * MIT license [LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT
 * Apache License, Version 2.0 [LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0

## Contribution <a name="contribution"/></a>
Unless you explicitly state otherwise, any contribution intentionally submitted for inclusion in
this project by you, as defined in the Apache-2.0 license, shall be dual licensed as above, without
any additional terms or conditions.

---

# Backlog <a name="backlog"/></a>
* Setup and document ruby on rails on linux

# Changelog <a name="changelog"/></a>
