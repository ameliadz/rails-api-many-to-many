class MoviesController < ApplicationController
  before_action :get_actor, only: [:index, :show, :create, :update]
  before_action :get_movie, only: [:show, :update]

  def index
    # @actor = Actor.find(params[:actor_id])
    @movies = @actor.movies
    render json: @movies, status: :ok
  end

  def show
    @movies = @actor.movies
    if @movies.include?(@movie)
      render json: @movie, include: :actors, status: :ok
    else
      render json: { message: "That movie doesn't seem to star that actor" }
    end
  end

  def create
    @movie = Movie.new(movie_params)
    if @movie.save
      @actor.movies.push(@movie)
      render json: @movie, status: :created
    else
      render json: { errors: @movie.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @movie.update(movie_params)
      render json: @movie, status: :ok
    else
      render json: { errors: @movie.errors }, status: :unprocessable_entity
    end
  end

  def destroy
  end

  private
  def movie_params
    params.require(:movie).permit(:title, :actor_id)
  end

  def get_actor
    @actor = Actor.find(params[:actor_id])
  end

  def get_movie
    @movie = Movie.find(params[:id])
  end

end
