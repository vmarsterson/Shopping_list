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
	end

	def call(env)
		req = Rack::Request.new(env)
		resp = Rack::Response.new

		if req.path == "/stylesheet.css"
			resp.write File.read("./stylesheet.css")
			return resp.finish
		end

		if req.env["REQUEST_METHOD"] == "POST" #post writes things onto the database directly from the user input. We're linking it to 
			item = req.POST["item"]
			quantity = req.POST["quantity"].to_i
			type = req.POST["type"]
			@db.execute("INSERT INTO products (item, quantity, type, bought) VALUES (?,?,?,?);", item, quantity, type, 0)
		end

		list = @db.execute("SELECT * FROM products;")
		resp.write ERB.new(@tpl).result(binding)
		resp.finish
	end
end


#make request object
#if req.path = style sheet, then respond with style sheet (File.read(path to style sheet))