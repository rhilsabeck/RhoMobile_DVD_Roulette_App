require 'rho/rhocontroller'
require 'helpers/browser_helper'

class MovieController < Rho::RhoController
  include BrowserHelper
  require 'json'

  # GET /Movie
  def index
    render :back => '/app/Movie'
  end
  
  def about
    render :action => :about
  end
  
  def addMovie
    render :action => :addMovie
  end
  
  
  def playRoulette
    render :action => :playRoulette
  end
  
  def wait
   render :action => :wait
  end
  
  def error
    @error = @params['id']
    render :action =>:error
  end

  def rouletteSelection

    @movie = Movie.find(:all)
    @size = @movie.size

    if @size==0
      @error = "There are no movies in your collection yet. Please add some!"
      redirect :action => :error, :id => @error
    else
      @randomMovie = @movie.sample
      render :action => :rouletteSelection  
    end
  end
  

  def getInfo()
      movieTitle = @params['Movie']
      movieYear = @params['Year']
      Rho::AsyncHttp.get(
        :url => "http://www.omdbapi.com/?t=#{movieTitle}&y=#{movieYear}&plot=short&r=json&type=movie",
        :callback => (url_for :action => :httpget_callback),
        :callback_param => "" )       
        redirect :action => :wait
  end
  
    def httpget_callback
     $httpresult = @params['body']
     jsonresult = Rho::JSON.parse($httpresult)
     
     @result = jsonresult["Response"]
     if @result == "True"
       @movie = Movie.create(
         {:title => jsonresult["Title"], :runtime => jsonresult["Runtime"],
          :year => jsonresult["Year"], :rated => jsonresult["Rated"], :released => jsonresult["Released"], 
          :genre => jsonresult["Genre"], :director =>jsonresult["Director"],
          :writer => jsonresult["Writer"], :actors => jsonresult["Actors"], :plot => jsonresult["Plot"],
          :poster => jsonresult["Poster"], :imdbID => jsonresult["imdbID"]}
       ) 

       Rho::WebView.navigate(url_for(:action => :show,:id => @movie.object))
     else
       @error = "This movie cannot be found. Try again."
       Rho::WebView.navigate(url_for(:action => :error, :id => @error))
       #redirect :action => :error 
     end    
  end
  
  def showAll
    @movies = Movie.find(:all, 
                         :order => 'title',
                         :orderdir => 'ASC')
    render :action => :showAll, :back => '/app/Movie'   
  end

  # GET /Movie/{1}
  def show
    @movie = Movie.find(@params['id'])
    if @movie
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end
  
  def imdbLink

    @movie = Movie.find(@params['id'])
    @imdbID = @movie.imdbID
    Rho::WebView.navigate("http://m.imdb.com/title/#{@imdbID}")
  end
  
  # POST /Movie/{1}/delete
  def delete
    @movie = Movie.find(@params['id'])
    @movie.destroy if @movie
    render :action => :delete  
  end
end


