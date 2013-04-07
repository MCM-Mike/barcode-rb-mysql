#!/Users/Casey/.rvm/rubies/ruby-2.0.0-rc1/bin/ruby
require 'rubygems'
require 'mysql'

$db = 'localhost'
$db_user = 'root'
$db_pass = ''
$db_name = 'inventory'

def open_connection
	begin
		db = Mysql.new($db, $db_user, $db_pass, $db_name)
	rescue Mysql::Error
		puts "Oops! Couldn't connect to database!"
	end
	puts "Connection successful!"
	return db
end

def display_contents
	db = open_connection()
	begin
		results = db.query "SELECT * FROM #{$db_name}"
		puts "Number of items: #{results.num_rows}"
		results.each_hash do |item|
			puts "Barcode: #{item['Barcode']}"
			puts "Item Name: #{item['ItemName']}"
			puts "Item Category: #{item['ItemCategory']}"
			puts "Quantity: #{item['Quantity']}"
			puts "Price: #{item['Price']}"
			puts "Description: #{item['Description']}"
			print "\n"
		end
		results.free
	ensure
		db.close
	end
end

def add_information
	db = open_connection()
	print "Enter Barcode: "
	barcode = gets.strip
	print "Enter Item Name: "
	item_name = gets.strip
	print "Item Category: "
	item_category = gets.strip
	print "Quantity: "
	quantity = gets.strip
	print "Price: "
	price = gets.strip
	print "Description: "
	description = gets.strip
	begin
		insert_new_item = db.prepare "INSERT INTO #{$db_name} (Barcode, ItemName, ItemCategory, Quantity, Price, Description) VALUES (?, ?, ?, ?, ?, ?)"
		insert_new_item.execute barcode,item_name,item_category,quantity,price,description
		insert_new_item.close
	rescue
		abort "There was an error adding information into the database."
	ensure
		db.close
	end
	puts "Information added successfully!"
end

def delete_information
	db = open_connection()
	print "Enter the barcode for the item you'd like to delete: "
	barcode = gets.strip
	begin
		delete_item = db.prepare "DELETE FROM #{$db_name} WHERE Barcode = ?"
		delete_item.execute barcode
		delete_item.close
	rescue
		abort "There was an error deleting item from the database. Please ensure that item exists."
	ensure
		db.close
	end
	puts "Information deleted successfully!"

end

def home_screen
	puts "Welcome to the Ruby/MySQL Inventory Application!"
	puts "What would you like to do?"
	puts "1: List Database Contents"
	puts "2: Enter New Item Into Database"
	puts "3: Remove Item From Database"
	user_choice = gets.strip
	case user_choice
	when "1"
		display_contents
	when "2"
		add_information
	when "3"
		delete_information
	else
		puts "You entered an incorrect option."
	end
end


home_screen()