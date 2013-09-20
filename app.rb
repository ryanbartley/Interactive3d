require 'rubygems'
require 'bundler'
Bundler.require
require 'bcrypt'
require 'babosa'
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
        session[:firstname].capitalize
    end
    def lastname
        session[:lastname].capitalize
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
	@people = Person.all(:order => :lastname.asc)
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
        erb :editpage
    else
        @page_title = "You're not logged in GO FUCK YOURSELF!!!!!!!!!!!!!!!!!!!"
        @page_heading = "You're not logged in GO FUCK YOURSELF!!!!!!!!!!!!!!!!!!!"
        erb :login
    end     
end

post '/editpage' do
	@p = Person.first(:email => session[:email])
	if @p
		@this_page = Page.first(:id => params[:pageid])
		@this_page.title = params[:title]
		@this_page.code = params[:code]
		@this_page.save
		:editpage
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

get '/forum' do
	@p = Person.first(:email => session[:email])
	@topics = Topic.all(:order => [ :created_at.desc ])
	if @p 
		@edit = true
		@page_title = "Question Forum"
		@page_heading = "Post your Questions or Answers!"
		erb :forum
	else
		@edit = false
		resetSession
		@page_title = "Question Forum"
		@page_heading = "Check out questions and answers!"
		erb :forum
	end
end

get '/addtopic' do
	@p = Person.first(:email => session[:email])
	if @p 
		@page_title = "Add Topic"
		@page_heading = "Add a topic!"
		erb :addtopic
	else
		resetSession
		@page_title = "Please Login"
		@page_heading = "Please Login"
		erb :login
	end
end

post '/topic' do
	@p = Person.first(:email => session[:email])
    if @p
    	@this_topic = Topic.new
        @topics = Topic.all
        @this_topic.createTopic(params[:title], params[:text], @p)
        @edit = true
        @page_title = "Question Forum"
		@page_heading = "Thanks for Posting!!!"
        erb :forum
    else
    	@edit = false
        @page_title = "You're not logged in GO FUCK YOURSELF!!!!!!!!!!!!!!!!!!!"
        @page_heading = "You're not logged in GO FUCK YOURSELF!!!!!!!!!!!!!!!!!!!"
        erb :login
    end     
end

get '/topic/:slug' do
	@p = Person.first(:email => session[:email])
	@this_topic = Topic.first(:slug => params[:slug])
	if @p
		@edit = true
		@page_title = "Question Forum"
		@page_heading = "Reply to this topic!"
		erb :addpost
	else
		@edit = false
		resetSession
		@page_title = "Please Login"
		@page_heading = "Please Login"
		erb :login
	end
end

post '/post' do
	@p = Person.first(:email => session[:email])
	@this_topic = Topic.first(:id => params[:id])
    if @p
    	@this_post = Post.new
        @this_post.createPost(params[:text], @this_topic, @p)
        @topics = Topic.all
        @edit = true
        @page_title = "Question Forum"
		@page_heading = "Thanks for Posting!!!"
        erb :forum
    else
    	@edit = false
        @page_title = "You're not logged in GO FUCK YOURSELF!!!!!!!!!!!!!!!!!!!"
        @page_heading = "You're not logged in GO FUCK YOURSELF!!!!!!!!!!!!!!!!!!!"
        erb :login
    end  
end

get '/delete/:page' do
	@p = Person.first(:email => session[:email])
	@this_page = Page.first(:slug => params[:page])
	if @p && @p.id == @this_page.person.id 
		@this_page.destroy!
		@owner = true
		@page_title = "Your Profile"
		@page_heading = "You successfully deleted your page!"
		erb :profile
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








