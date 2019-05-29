[![General Assembly Logo](https://camo.githubusercontent.com/1a91b05b8f4d44b5bbfb83abac2b0996d8e26c92/687474703a2f2f692e696d6775722e636f6d2f6b6538555354712e706e67)](https://generalassemb.ly)

# Rails API -- Many to Many Association
Many-to-Many relationships arise when one or more records in a table, has a relationship with one or more records in another table.

Many-to-many relationships are fairly common in applications. Some examples include:

- Blog Posts can be sorted into multiple Categories, Categories contain many Blog Posts
- Theaters can show many Movies, and Movies may appear in many Theaters
- Playlists contain many Songs, Songs can be on multiple Playlists
- Doctors can have many Patients, a Patient can have more than one Doctor

## Getting Started
Create a new Rails application:

```
$ rails new books_db_api --api --database=postgresql -JSTCMG --skip-turbolinks --skip-coffee --skip-active-storage --skip-bootsnap
$ cd books_db_api
```

**Reminder:** Adding the `--api` will do three main things for you:

1. Configure your application to start with a more limited set of middleware than normal. Specifically, it will not include any middleware primarily useful for browser applications (like cookies support) by default.
2. Make ApplicationController inherit from ActionController::API instead of ActionController::Base. As with middleware, this will leave out any Action Controller modules that provide functionalities primarily used by browser applications.
3. Configure the generators to skip generating views, helpers and assets when you generate a new resource.

Read more about _Using Rails for API-only Applications_ in the documentation [here](https://guides.rubyonrails.org/api_app.html).

Set up an empty database:

```
$ rails db:create
```
Open the project in the current directory using your text editor:

```
$ subl .
```

## Generate Models
We're going to make two models: "books" and "authors". In this world, every book can have multiple authors and every author can write multiple books, so they'll need a many to many relationship. There are several ways to do this, [which you can see here](https://www.sitepoint.com/master-many-to-many-associations-with-activerecord/).

The simplest way is using the _has_and_belongs_to_many_ association. The _has_and_belongs_to_many_ association creates a direct many-to-many connection with another model, with no intervening model:

```
rails g model Author name:string
rails g model Book title:string
rails g migration CreateJoinTableAuthorsBooks authors books <-- join table models must be in alphabetical order
```
> Note: Check the `db/migrate` folder after each step.

The last command is going to generate a migration file (if you want the indexes in the migration file, uncomment the two t.index﻿ lines). 

Then, create the database tables:

```
rails db:migrate
```

> Note: Check the `db/schema.rb` file

After updating our database with the migration, define both sides fo the relationship between the Book:

```
class Book < ApplicationRecord
  has_and_belongs_to_many :authors
end
```
and Author models with the _has_and_belongs_to_many_ association:

```
class Author < ApplicationRecord
  has_and_belongs_to_many :books
end
```

Copy the seed data from this repository and paste it in your `seed.rb` file in your `db folder`.  Once you've done that and saved the file, run `rails db:seed` in your terminal.

Feel free to open up your rails console and take a look at this seed data.

<details>
<summary>Hint:</summary>

- Author.first.books <-- lists all the books written by Tom Clancy
- Book.last.authors <-- lists all the authors who contributed to the last book
- Book.find(1).authors <-- similar to above
</details>

## Set Up Routes
Let's add CRUD routes for our two new tables. There are a lot of different ways to write routes, [you can see a few here](https://git.generalassemb.ly/wdi-nyc-bananas/rails_routes). For this api, we're going to use `scope`. 

The format for the scope method looks like the following:
```
scope 'url_prefix' do
	resources :resource_name
end
```

Head to your `routes.rb` file in your `config` folder and add the scoped routes for your models:

```
scope '/authors/:author_id' do
  resources :books
end

scope '/books/:book_id' do
  resources :authors
end
```

<details>
<summary>The routes for the first scope will look something like the following:</summary>

```
  books GET    /authors/:author_id/books(.:format)     books#index
        POST   /authors/:author_id/books(.:format)     books#create
   book GET    /authors/:author_id/books/:id(.:format) books#show
        PATCH  /authors/:author_id/books/:id(.:format) books#update
        PUT    /authors/:author_id/books/:id(.:format) books#update
        DELETE /authors/:author_id/books/:id(.:format) books#destroy
```
</details>

Next, launch the server:

```
$ rails server
```

Then, visit the followng link in the browser:

```
http://localhost:3000/authors/1/books
```

## Create Controller

Create a new file in your controllers folder called `books_controller.rb `. Add a `BooksController` class that inherits from the `ApplicationController`. Let's take a look at the index action (and the associated GET route):

```
  # /authors/:author_id/books
  
  def index
    @author = Author.find(params[:author_id])
    @books = @author.books
    render json: @books, include: :authors, status: :ok
  end
```

We use `Author.find` to find the author we're interested in, passing in `params[:author_id]` to get the :id parameter from the request. We use an instance variable (prefixed with @) to hold a reference to the author object.

We use the instance of `@author` to grab all its associated books and use the an instance variable to hold a reference to `@books`. 

Finally, we want to render @books as JSON, and include the association :authors on the Book model in the exported data. You should see JSON data showing books.

Now, let's fill out the rest of the CRUD actions:

```
class BooksController < ApplicationController
  ...
  
  # /authors/:author_id/books/2
  def show
    @book = Book.find(params[:id])
    render json: @book, include: :authors, status: :ok
  end

  def create
    @author = Author.find(params[:author_id])
    @book = Book.new(book_params)
    
    if @book.save
      @author.books.push(@book)
      render json: @book, status: :created
    else
      render json: { errors: @book.errors }, status: :unprocessable_entity
    end
  end

  def update
    @author = Author.find(params[:author_id])
    @book = Book.find(params[:id])
    
    if @book.update(book_params)
      render json: @book, status: :ok
    else
      render json: { errors: @book.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    head :no_content
  end

  private

  def book_params
    params.require(:book).permit(:title, :author_id)
  end
end
```

## Preventing CORS Issues
When you build APIs will Rails, chances are you might encounter some Cross-Origin errors. This is because your Rails API is not equipped to accept POST, PUT or DELETE requests from sources (or "origins") other than itself. The [Rack Middleware for handling CORS](https://github.com/cyu/rack-cors) gem is a useful tool in tackling that problem. Add the following to your Gemfile:

```
gem 'rack-cors', :require => 'rack/cors'
```

Next, head to the `application.rb` file in your `config` folder and, inside the Application class, add the following:

```
config.middleware.use Rack::Cors do
  allow do
    origins '*'
    resource '*', :headers => :any, :methods => [:get, :post, :put, :options, :delete], :credentials => false
  end
end
```
 
This should allow a client app to make requests without issue. 

## Independent Exercise

Your turn! Using this guide, make a rails API from scratch with a many to many relationship of Movies and Actors. A movie stars many actors and an actor stars in many movies. Feel free to keep the columns limited to just names and titles (or go wild and add extra details if you'd like).

As you're building, make sure to check your routes using `rails routes` and check your database in the terminal console using `rails c`. 

When building your first controller, start with your _index_ and _show_ actions. Once those look good, check them by starting your rails server and visiting their URLs in the browser. You should see JSON data that accurately reflects your database getting rendered on the page.

Once you've made it that far, you can use an app like Postman to check your CUD routes OR you can just get building the second part of this lab: a React front end that hits and utilizes these endpoints.

**TL;DR: Build a rails API and hit the endpoints with a React front end**
