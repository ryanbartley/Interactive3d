DataMapper::setup(:default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite")

DataMapper::Model.raise_on_save_failure = true

class Person
 	include DataMapper::Resource
 	include BCrypt
	
 	property :id, Serial
 	property :firstname, 	String
 	property :lastname, 	String
 	property :email, 		String
 	property :password,		BCryptHash
	
 	has n, :pages, :through => Resource
	
 	def createPerson(firstname, lastname, email, password)
 		self.firstname = firstname.downcase
 		self.lastname = lastname.downcase
 		self.email = email.downcase
 		self.password = password
 		self.save
 	end

 	def savePage(page)
 		self.pages << page
 		self.save 
 	end

 	def getPages
 		self.pages.all
 	end

 	def name
 		self.firstname.capitalize + " " + self.lastname.capitalize
 	end
end

class Page
	include DataMapper::Resource
	property :id, 			Serial
	property :title, 		String
	property :code, 		Text
	property :created_at, 	DateTime
	property :slug, 		String, :default => lambda { | resource, prop| resource.title.downcase.gsub " ", "" }

	belongs_to :person

	def createPage(title, code, person)
		self.title = title
		self.code = code
		self.created_at = DateTime.now
		person.pages << self
		self.save
	end
end

DataMapper.finalize
DataMapper.auto_upgrade!