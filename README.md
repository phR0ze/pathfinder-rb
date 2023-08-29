# pathfinder-rb
[![License: MIT](https://img.shields.io/badge/License-MIT/Apache%202.0-blue.svg)](https://opensource.org/licenses/MIT)

***Simple point tracker in Ruby on Rails***

### Quick links
* [Deployment](#deployment)
  * [Build container](#build-container)
  * [Run on server](#run-on-server)
  * [Run manually](#run-manually)
* [Ruby on Rails](#ruby-on-rails)
  * [Overview](#overview)
  * [Deploy Rails on Arch Linux](#deploy-rails-on-arch-linux)
    * [Install Rails](#install-rails)
    * [Create Rails app](#create-rails-app)
    * [Migrate to new server](#migrate-to-new-server)
    * [Run your app](#run-your-app)
  * [Rails Application](#rails-application)
    * [Routes](#routes)
    * [Controllers](#controllers)
    * [Views](#views)
    * [Models](#models)
  * [Populate Data](#populate-data)
    * [Console](#console)
    * [DB Console](#db-console)
    * [Validate](#validate)
  * [Users Controller](#users-controller)
    * [List Users](#list-users)
    * [Add audio](#add-audio)
  * [Points Controller](#points-controller)
    * [New Points](#new-points)
  * [Rewards Controller](#rewards-controller)
    * [New Rewards](#new-rewards)
  * [History Controller](#history-controller)
* [Contribute](#contribute)
  * [Git-Hook](#git-hook)
* [License](#license)
  * [Contribution](#contribution)
* [Backlog](#backlog)
* [Changelog](#changelog)

---

# Deployment

## Build container
1. Clone pathfinder repo
   ```bash
   $ git clone https://github.com/phR0ze/pathfinder-rb 
   ```
2. Build the container
   ```bash
   $ cd pathfinder-rb
   $ docker build -t pathfinder-rb .
   ```

## Run on server
1. Restore data as needed
   ```bash
   $ cp ~/Storage/Backup/development.sqlite3 ~/Projects/pathfinder-rb/db
   ```
2. Execute
   ```
   $ docker run --rm -v $(pwd):/usr/src/app -p 3000:3000 -e TZ=America/Boise pathfinder-rb
   ```

## Run manually
1. Execute app in shell
   ```bash
   $ docker run --rm -v $(pwd):/usr/src/app -p 3000:3000 pathfinder-rb
   ```
2. Navigate in a browser to `http://127.0.0.1:3000`

---

# Ruby on Rails
Documenting the process I went through to create this basic Rails app

## Overview
Rails is a web application framework running on the Ruby runtime. It is designed to make programming 
web applications easier by making assumptions about what every developer needs to get started. It 
allows you to write less code while accomplishing more. If you learn ***The Rails Way*** the sales 
pitch is you'll be productive faster. ***The Rails Way*** is based heavily on convention and is 
highly opinionated.

References:
* [Ruby Documentation](https://www.ruby-lang.org/en/documentation/)
* [Getting Started with Ruby on Rails](https://guides.rubyonrails.org/getting_started.html)

## Deploy Rails via Docker

### Create Rails app
The following steps create a new Rails app. Since we're creating the Rails app in an existing rep we 
use the `--skip-git` and move the generated content up one dir.

1. Create a new rails app via the `alpine-rails` image:
   ```bash
   $ docker run --rm -v $(pwd):/usr/src/app phR0ze/alpine-rails:3.16 rails new pathfinder --skip-git --minimal
   ```
2. Move the new app bits up one directory
   ```bash
   $ move pathfinder/* .
   $ rmdir pathfinder
   ```

## Deploy Rails on Arch Linux
* [Getting Started with Ruby on Rails](https://guides.rubyonrails.org/getting_started.html)

### Install Rails
1. Install the prerequisites:
   ```bash
   $ sudo pacman -S ruby sqlite nodejs yarn clang make pkg-config sqlitebrowser
   ```
2. Add the ruby bin path to $PATH
   ```bash
   $ PATH=PATH:$HOME/.local/share/gem/ruby/3.0.0/bin
   ```
3. Install Rails:
   ```bash
   $ gem install rails
   $ gem update

   $ rails --version
   Rails 6.1.4
   ```

### Create Rails app
```bash
$ rails new pathfinder
```

### Migrate to new server
When migrating to a new server you'll need to run the `bundle install`
```bash
$ cd pathfinder
$ gem install bundler
$ bundle install
```

### Upgrading server breakages
After a server upgrade anything ruby or rails related is usually broken because the specific 
gems installed depend on a specific version of ruby or a specific version of native libraries; both 
of which were probably upgraded and changed during the system upgrade. Additionally ruby doesn't have 
a good way to clean out all the broken gems:

NOTE: you can avoid this entirely by [containerizing your app](https://github.com/phR0ze/alpine-rails#build)
then [running on a server](#run-on-server)

1. If the Ruby version changes e.g. `3.0.2` to `3.0.3`  
   a. Update the `Gemfile` Ruby version e.g. `3.0.2` to `3.0.3`  
   b. Remove the lock file: `rm Gemfile.lock`  

2. Find your current gem paths
   ```bash
   $ gem env
   ...
   - INSTALLATION DIRECTORY: /usr/lib/ruby/gems/3.0.0
   - USER INSTALLATION DIRECTORY: ~/.local/share/gem/ruby/3.0.0
   ...
   ```

3. Delete them
   ```bash
   $ sudo rm -rf /usr/lib/ruby/gems/3.0.0
   $ rm -rf ~/.local/share/gem/ruby/3.0.0
   ```

4. Reinstall ruby
   ```bash
   $ sudo pacman -S ruby --overwrite '*'
   ```

5. Install rails and your bundle
   ```bash
   $ gem install rails
   $ gem install bundler
   $ bundle install
   ```

### Run your app
Running your app locally with it bound to all NICs allows other machines on your network to pull it
up by your network address i.e. `192.168.1.4:3000/users` not just `127.0.0.1:3000/users`

1. Start your new web application
   ```bash
   $ cd pathfinder
   $ bin/rails server -b 0.0.0.0
   ```

2. Navigate in a browser to `http://127.0.0.1:3000`

## Rails Application
The Rails Way makes extensive use of the `MVC (Model View Controller)` pattern. Routes, controllers,
actions, models and views are all typical pieces. MVC is a design pattern that divides the
responsibilities of an application to make it easier to reason about.

* `route` maps a request to a controller action
* `controller` controller provides grouping for actions
* `action` functions on the controller that perform the actual work
* `model` keeps data together separate from the other components
* `view` displays the data in a desired format

In this case we'll be building a simple application that allows a user to add students, define
categories and assign a positive or negative amount of points in a category to a given student and
have the ability to see the aggregate points for the day, previous day or all time.

### Routes
Routes are rules written in a [Ruby DSL(Domain Specific Language)](https://guides.rubyonrails.org/routing.html). 

Add our new routes to `config/routes.rb`
```ruby
Rails.application.routes.draw do
  resources :users do
    resources :points
    resources :rewards
  end
  resources :history
  resources :categories
end
```

### Controllers
Controllers are Ruby classes and their public methods are actions.

1. Run the docker container tools we'll need:
   ```bash
   $ docker run --rm -it -v $(pwd):/usr/src/app -p 3000:3000 pathfinder-rb bash
   ```
2. Generate the controllers we'll need:
   ```bash
   $ rails generate controller Users index --skip-routes
   $ rails generate controller Points index --skip-routes
   $ rails generate controller History index --skip-routes
   $ rails generate controller Rewards index --skip-routes
   $ rails generate controller Categories index --skip-routes
   ```
Note: Rails will create a few files per controler e.g.:
* `app/controllers/users_controller.rb` the controller file
* `app/views/users/index.html.rb` the view file

### Views
Views are templates, usually written in a mixture of HTML and Ruby

Update the index file with our hello message:
```bash
$ echo "<h1>Hello Rails</h1>" > app/views/users/index.html.rb
```

### Models
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

1. Run the docker container tools we'll need:
   ```bash
   $ docker run --rm -it -v $(pwd):/usr/src/app -p 3000:3000 pathfinder-rb bash
   ```

2. Create the models we'll need for our app:
   ```bash
   $ rails generate model User name:string
   $ rails generate model Category name:string value:integer
   $ rails generate model Reward value:integer user:references
   $ rails generate model Point value:integer user:references category:references
   ```

3. Run the resulting migrations to create the proper tables:
   ```bash
   $ rails db:migrate
   ```

## Populate Data

### Console
1. Launch the console:
   ```bash
   $ docker run --rm -it -v $(pwd):/usr/src/app -p 3000:3000 pathfinder-rb rails console
   ```
2. Create a new user and save it to the database. Once the user is saved the user object gets updated
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

   # Print out the model schema after loading it with User.all
   $ User
   ```

### DB Console
Rails also has a dedicated Database console with databasse related commands available
```bash
$ bin/rails db

# You can see the current tables with the `.table` command
sqlite> .table
ar_internal_metadata  points                users
categories            schema_migrations

# List out help
sqlite> .help

# List out the database file
sqlite> .databases
main: /Projects/pathfinder/db/development.sqlite3 r/w

# Quite
sqlite> .quit
```

## Users Controller

### List Users
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

### Add audio
To add a sound clip we can play when given a user points we need to:

1. Add the new sound to `app/assets/audios`
   ```bash
   cp success.wav app/assets/audios
   ```
2. Restart the server `bin/rails server -b 0.0.0.0`
3. Using the new audio file in your view requires injecting the audio element
   ```html
   <%= audio_tab "success.wav", id: "audio_success" %>
   ```
4. Then setting up an onclick to fire it
   ```html
   <div onclick="play()">Click me</div>
   ```
5. Finally setup the javascript to call back and play the audio
   ```html
   function play() {
     document.getElementById("audio_success").play();
   }
   ```

## Points Controller
Rails has a helper called `resources` that maps all CRUD operations for an endpoint to the
controller. We can edit `config/routes.rb` and replace our points entry with `resources :points` to
get all CRUD operations mapped to our points controller. To establish the relationship between users
and points we need to nest the points routes.

```ruby
Rails.application.routes.draw do
  resources :users do
    resources :points
  end
end
```

You can see the current routes via rails
```bash
$ bin/rails routes
Prefix            Verb   URI Pattern                                    Controller#Action
user_points       GET    /users/:user_id/points(.:format)               points#index
                  POST   /users/:user_id/points(.:format)               points#create
new_user_point    GET    /users/:user_id/points/new(.:format)           points#new
edit_user_point   GET    /users/:user_id/points/:id/edit(.:format)      points#edit
user_point        GET    /users/:user_id/points/:id(.:format)           points#show
```

The `Prefix` colum calls out the shortcut route string that can be used in your application to route
to a particular view. For example `new_user_point` suffixed with `_path` can be used in the
templating with `<%= link_to new_user_point_path(reward) do %>` will load the new user points view.

### New Points
1. Edit the points controller `app/controllers/points_controller.rb` and add the following functions.
   The `new` function is used to create a new instance but not save it and the `create` to save out a
   fully populated instance.
   ```ruby
   def new
     @point = Point.new
   end
   def create
     @user = User.find(params[:user_id])
     success = true
     fields = params[:point]
     fields.each do |category_id, value|
       point = Poin.new(value: value, user_id: @user.id, category_id: category_id)
       success = false if !point.save
     end
     if success
       redirect_to users_url
     else
       render :new
     end
   end
   ```

### Validate
1. Start the rails app back up
   ```bash
   $ bin/rails server
   ```
2. Navigate in a browser to `http://127.0.0.1:3000/users`

## Rewards Controller
We can use a similar relationship routing update as the points controller to add in the rewards
relationship to users in the `config/routes.rb` router.

```ruby
Rails.application.routes.draw do
  resources :users do
    resources :points
    resources :rewards
  end
end
```

You can see the current routes via rails
```bash
$ bin/rails routes
Prefix            Verb   URI Pattern                                    Controller#Action
...
user_rewards      GET    /users/:user_id/rewards(.:format)              rewards#index
                  POST   /users/:user_id/rewards(.:format)              rewards#create
new_user_reward   GET    /users/:user_id/rewards/new(.:format)          rewards#new
edit_user_reward  GET    /users/:user_id/rewards/:id/edit(.:format)     rewards#edit
user_reward       GET    /users/:user_id/rewards/:id(.:format)          rewards#show
```

We can see that the appropriate shorcut route string will be `new_user_reward` plus the suffix `_path`.

### New Rewards
1. Editing the rewards controller `app/controllers/rewards_controller.rb` and add the following functions.
   The `new` function is used to create a new instance but not save it and the `create` to save out a
   fully populated instance.
   ```ruby
   ```
2. Editing the rewards view `app/views/rewards/index.html.rb`
   ```html
   ```
3. Update the rewards relationship to users `app/models/user.rb` to establish the `@user.rewards`
   data aggregate i.e. rails will automatically pull all rewards for the give user and populate the
   property on the user class.
   ```ruby
   class User < ApplicationRecord
     has_many :points
     has_many :rewards
   end
   ```

## History Controller
Documenting adding a new history controller to present a user's data per category over a period of 
time.

1. Create the new controller:
   ```bash
   $ bin/rails generate controller History index --skip-routes
     create  app/controllers/history_controller.rb
     invoke  erb
     create    app/views/history
     create    app/views/history/index.html.erb
     invoke  test_unit
     create    test/controllers/history_controller_test.rb
     invoke  helper
     create    app/helpers/history_helper.rb
     invoke    test_unit
     invoke  assets
     invoke    scss
   ```
2. Update the routing table `config/routes.rb`:
   ```ruby
   Rails.application.routes.draw do
     resources :users do
       resources :points
       resources :rewards
     end
     resources :history
     resources :categories
   end
   ```
3. Check the current routes via rails:
   ```bash
   $ bin/rails routes
   Prefix            Verb   URI Pattern                                    Controller#Action
   ...
   history_index     GET    /history(.:format)                             history#index
   new_history       GET    /history/new(.:format)                         history#new
   edit_history      GET    /history/:id/edit(.:format)                    history#edit
   history           GET    /history/:id(.:format)                         history#show
   ```
4. We'll be building out an index page using `history_index_path`

---

# Contribute
Pull requests are always welcome. However understand that they will be evaluated purely on whether
or not the change fits with my goals/ideals for the project.

## Git-Hook
Enable the git hooks to have automatic version increments
```bash
cd ~/Projects/clu
git config core.hooksPath .githooks
```

# License
This project is licensed under either of:
 * MIT license [LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT
 * Apache License, Version 2.0 [LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0

## Contribution
Unless you explicitly state otherwise, any contribution intentionally submitted for inclusion in
this project by you, as defined in the Apache-2.0 license, shall be dual licensed as above, without
any additional terms or conditions.

---

# Backlog
* Setup and document ruby on rails on linux

# Changelog

<!-- 
vim: ts=2:sw=2:sts=2
-->
