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
 	has n, :topics, :through => Resource
 	has n, :posts, :through => Resource
	
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
	property :slug, 		String #, :default => lambda { | resource, prop| resource.title.downcase.gsub " ", "" }

	belongs_to :person

	def createPage(title, code, person)
		self.title = title
		self.slug = title.to_slug.word_chars.to_s 
		self.slug = self.slug.downcase.gsub " ", ""
		self.code = code
		self.created_at = DateTime.now
		self.person_id = person.id
		self.save
		person.pages << self
		person.save
	end

	def updatePage(title, code)
		self.title = title
		self.code = code
		self.save
	end
end

class Topic
	include DataMapper::Resource
	property :id,	Serial	
	property :title, 		String
	property :text, 		Text
	property :created_at, 	DateTime
	property :slug,			String #, :default => lambda { | resource, prop| resource.title.downcase.gsub " ", "" }

	belongs_to :person
	has n, :posts, :through => Resource

	def createTopic(title, text, p)
		self.title = title
		self.text = text
		self.slug = title.to_slug.word_chars.to_s 
		self.slug = self.slug.downcase.gsub " ", ""
		self.created_at = DateTime.now
		self.person_id = p.id 
		p.topics << self
		p.save 
		self.save
	end

end

class Post
	include DataMapper::Resource
	property :id, 			Serial
	property :text, 		Text
	property :created_at, 	DateTime

	belongs_to :topic
	belongs_to :person

	def createPost(text, topic, p)
		self.text = text
		self.created_at = DateTime.now
		self.person_id = p.id
		self.topic_id = topic.id
		topic.posts << self
		p.posts << self
		topic.save
		p.save
		self.save 
	end
end

DataMapper.finalize
DataMapper.auto_upgrade!