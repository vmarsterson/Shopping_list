#this is where you define all of your classes
# require_relative './stylesheet.css'

require "sqlite3"
require "rack"
require "erb"

class App

	def initialize
		@tpl = File.read ("./index.erb")
		@style = File.read ("./stylesheet.css")
		@db = SQLite3::Database.new("./database.db")
		@db.execute("CREATE TABLE IF NOT EXISTS products (id INTEGER PRIMARY KEY, item TEXT, quantity INTEGER, type TEXT, bought INTEGER);") #database created
		@db.execute("CREATE TABLE IF NOT EXISTS names (id INTEGER PRIMARY KEY, name TEXT);")
		@db.execute("SELECT name FROM names LIMIT 1;") do |row|
			@name = row.first
		end
	end

	def insert_name name
		puts name
		@db.execute("INSERT INTO names (name) VALUES (?);", name)
		@name = name
	end

	# def product_table (item, quantity, type)

	# end

	def call(env)
		req = Rack::Request.new(env)
		resp = Rack::Response.new

		time = Time.now.strftime("%d.%m.%y")

		if req.path == "/stylesheet.css"
			resp.write File.read("./stylesheet.css")
			return resp.finish
		end

		if req.env["REQUEST_METHOD"] == "POST" #post writes things onto the database directly from the user input. We're linking it to
			
			if req.path == "/name" then insert_name(req.POST["name"]) end
			if req.path == "/products" then
				item = req.POST["item"].capitalize
				quantity = req.POST["quantity"].to_i
				type = req.POST["type"].capitalize
				@db.execute("INSERT INTO products (item, quantity, type, bought) VALUES (?,?,?,?);", item, quantity, type,  0) 
			end
			if req.path == "/products/clear"
				clear = req.POST["clear"]
				@db.execute("DELETE FROM products")
			end

		end

		list = @db.execute("SELECT * FROM products ORDER BY type ASC;")
		resp.write ERB.new(@tpl).result(binding)
		resp.finish
	end
end


#make request object
#if req.path = style sheet, then respond with style sheet (File.read(path to style sheet))