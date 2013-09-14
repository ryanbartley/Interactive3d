require 'rubygems'
require 'bundler'
Bundler.require
require 'bcrypt'
require 'date'
require './database.rb'

set :root, File.dirname(__FILE__)

enable :sessions

def resetSession
	session[:email] = nil
	session[:firstname] = nil
	session[:lastname] = nil
end

helpers do
    def login?
        if session[:email] == nil
          return false
        else
          return true
        end
    end
    def username
        session[:email]
    end
    def firstname
        session[:firstname] 
    end
    def lastname
        session[:lastname]
    end
end


get '/' do
	@page_title = "Interactive 3d Programming"
  	erb :index
end

get '/signup' do
	@page_title = "Sign Up"
	@page_heading = "Enter a new username and password!"

	erb :signup
end

post '/signedup' do
	match = Person.first(:email => params[:email])
	if !match
		if params[:password] == params[:checkpassword]
			@p = Person.new
			@p.createPerson(params[:firstname], params[:lastname], params[:email], params[:password])
			session[:email] = @p.email
			session[:firstname] = @p.firstname
			session[:lastname] = @p.lastname
			@page_title = "Profile"
			@page_heading = "Add or delete pages!"
			erb :profile
		else
			@page_title = "Please Retype Your Password"
			@page_heading = "Please Enter Your Username And Password"
			erb :profile
		end
	else
		@page_title = "Please Check Email!"
		@page_heading = "That email is already in use"
		erb :login
	end
end

post '/login' do
	match = Person.first(:email => params[:email])
	if match
		@p = match
		if @p.password == params[:password]
			@page_title = "Profile"
			session[:email] = @p.email
			session[:firstname] = @p.firstname.capitalize
			session[:lastname] = @p.lastname.capitalize
			redirect '/profile'
		else
			@page_title = "Please Check Password"
			@page_heading = "Please Check Password"
			erb :login
		end
	else
		@page_title = "Please Check Email!"
		@page_heading = "That email is already in use"
		erb :login
	end
end

get '/profile' do
	@p = Person.first(:email => session[:email])
	if @p 
		@page_title = "Your Profile"
		@page_heading = "Your Profile"
		erb :profile
	else
		resetSession
		@page_title = "Please Login"
		@page_heading = "Please Login"
		erb :login
	end
end

get '/pages' do
	@people = Person.all
	erb :pages
end

get '/pages/:page' do
	@p = Person.first(:email => session[:email])
	@this_page = Page.first(:slug => params[:page])
	if session[:email] && session[:firstname] && session[:lastname]
		if @p && @p.id == @this_page.person.id 
			@owner = true
			@page_title = "Edit Page"
			@page_heading = "You can edit, add or delete code and submit when finished!"
			erb :singlepage
		else
		
			@owner = false
			@page_title = @this_page.title
			@page_heading = @this_page.title
			erb :singlepage
		end
	else
		resetSession 
		@owner = false
		@page_title = @this_page.title
		@page_heading = @this_page.title
		erb :singlepage
	end
end

get '/addpage' do
	@p = Person.first(:email => session[:email])
	if @p 
		@page_title = "Add Page"
		@page_heading = "Add your new page!"
		erb :addpage
	else
		resetSession
		@page_title = "Please Login"
		@page_heading = "Please Login"
		erb :login
	end
end

post '/newpage' do
    @p = Person.first(:email => session[:email])
    if @p
        @this_page = Page.new
        @pages = Page.all
        @this_page.createPage(params[:title], params[:code], @p)
        @owner = true
        @page_title = "Edit Page"
		@page_heading = "You can edit, add or delete code and submit when finished!"
        erb :singlepage
    else
        @page_title = "You're not logged in GO FUCK YOURSELF!!!!!!!!!!!!!!!!!!!"
        @page_heading = "You're not logged in GO FUCK YOURSELF!!!!!!!!!!!!!!!!!!!"
        erb :login
    end     
end

get '/edit/:page' do
	@p = Person.first(:email => session[:email])
	@this_page = Page.first(:slug => params[:page])
	if @p && @p.id == @this_page.person.id 
		@owner = true
		@page_title = "Edit Page"
		@page_heading = "You can edit, add or delete code and submit when finished!"
		erb :editpage
	else
		@owner = false
		resetSession
		@page_title = "Please Login"
		@page_heading = "Please Login"
		erb :login
	end
end

get '/logout' do
    resetSession
    redirect "/"
end

get '/about' do
	erb :about
end








