class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.select(:rating).distinct.map{|record| record.rating}.sort
    @all_ratings_params = Hash[@all_ratings.map {|u| [u, 1]}]
    if params.has_key?(:ratings)
      @selected_ratings = params[:ratings].keys 
      session[:ratings] = @selected_ratings
    elsif session.has_key?(:ratings)
      @selected_ratings = session[:ratings]
    else
      @selected_ratings = @all_ratings
      session[:ratings] = @selected_ratings
    end
    @selected_ratings_params = Hash[@selected_ratings.map {|u| [u, 1]}]
    if not params.has_key?(:ratings) and session.has_key?(:ratings)
      flash.keep
      redirect_to controller: 'movies', action: 'movies', sort: session[:sort], utf8: "✓", ratings: @selected_ratings_params, commit: "Refresh" and return
    end
    @movies = Movie.where(rating: @selected_ratings)
    if params.has_key?(:sort)
      @sort = params[:sort]
      session[:sort] = @sort
    elsif session.has_key?(:sort)
      @sort = session[:sort]
    else
      @sort = ""
    end
    if not params.has_key?(:sort) and session.has_key?(:sort)
      flash.keep
      redirect_to controller: 'movies', action: 'movies', sort: session[:sort], utf8: "✓", ratings: @selected_ratings_params, commit: "Refresh" and return
    end
    if @sort == "title"
      @movies = @movies.order("title")
    elsif @sort == "release_date"
      @movies = @movies.order("release_date")
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
