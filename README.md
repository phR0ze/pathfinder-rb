# pathfinder-rb
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![License: Apache2](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

***Simple point tracker in Ruby on Rails***

### Quick links
* [Ruby on Rails](#ruby-on-rails)
  * [Deploy Rails on Arch Linux](#deploy-rails-on-arch-linux)
  * [Say Hello Rails](#say-hello-rails)
    * [Route](#route)
    * [Controller](#controller)
    * [View](#view)
    * [Validate](#validate)
  * [Model View Controller](#model-view-controller)
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
   $ sudo pacman -S ruby sqlite nodejs yarn clang make pkg-config 
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
   $ bin/rails server
   ```
6. Navigate in a browser to `http://127.0.0.1:3000`

## Say Hello Rails <a name="say-hello-rails"/></a>
The Rails Way to say `Hello` is to create a:
* `route` maps a request to a controller action
* `controller` controller action performs the necessary work for the request
* `view` displays the data in a desired format

### Route <a name="route"/></a>
Routes are rules written in a [Ruby DSL(Domain Specific Language)](https://guides.rubyonrails.org/routing.html). 

Add a new `users` route to `config/routes.rb`
```ruby
Rails.application.routes.draw do
  get "/users", to: "users#index"
end
```

The route above declares that `GET /users` is mapped to the `index` of the `UsersController`. 

### Controller <a name="controller"/></a>
Controllers are Ruby classes and their public methods are actions.

Generate the new `UsersController`
```bash
$ bin/rails generate controller Users index --skip-routes
```

Rails creates a few files:
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

### Validate <a name="validate"/></a>
1. Start the rails app back up
   ```bash
   $ bin/rails server
   ```
2. Navigate in a browser to `http://127.0.0.1:3000/users`

## Model View Controller <a name="model-view-controller"/></a>
Routes, controllers, actions and views are all typical pieces of the `MVC (Model View Controller) pattern`.
MVC is a design pattern that divides the responsibilities of an application to make it easier to
reason about. Rails follows this design pattern by convention.

### Generating a Model <a name="generating-a-model"/></a>
A `model` is a Ruby class that is used to represent data. Additionally models can interact with the
appliation's database through a feature of Rails called `Active Record`.

Use rails to generate a model for you:
```bash
$ bin/rails generate model User
```

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
