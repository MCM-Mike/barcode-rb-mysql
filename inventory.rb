#!/Users/Casey/.rvm/rubies/ruby-2.0.0-rc1/bin/ruby
require 'rubygems'
require 'mysql'

# Set global variables for the database hostname, user, password, and name
$db = 'localhost'
$db_user = 'root'
$db_pass = ''
$db_name = 'inventory'

# This function opens a connection to the database
def open_connection
	begin
		db = Mysql.new($db, $db_user, $db_pass, $db_name)
	rescue Mysql::Error
		puts "Oops! Couldn't connect to database!"
	end
	puts "Database connection successful!"
	return db
end

# This function displays the contents of the database
def display_contents
	# Open connection
	db = open_connection
	begin
		# Set results equal to the result of the MySQL query
		results = db.query "SELECT * FROM #{$db_name}"
		puts "Number of items: #{results.num_rows}"

		# Loop through the results and output the data
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

# This function allows the user to add information into the database
def add_information
	# Open connection
	db = open_connection

	# Get user input
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

	begin # Prepare database query and execute it
		insert_new_item = db.prepare "INSERT INTO #{$db_name} (Barcode, ItemName, ItemCategory, Quantity, Price, Description) VALUES (?, ?, ?, ?, ?, ?)"
		insert_new_item.execute barcode,item_name,item_category,quantity,price,description
		insert_new_item.close
	rescue # Catch any errors
		abort "There was an error adding information into the database."
	ensure # Close the connection to the database
		db.close
	end
	puts "Information added successfully!"
end

# This function allows the user to delete information from the database
def delete_information
	# Open connection
	db = open_connection
	# Get user input
	print "Enter the barcode for the item you'd like to delete: "
	barcode = gets.strip
	begin # Check if barcode exists
		delete_item = db.prepare "DELETE FROM #{$db_name} WHERE Barcode = ?"
		delete_item.execute barcode
		delete_item.close
	rescue # Catch any errors
		abort "There was an error deleting item from the database. Please ensure that item exists."
	ensure # Close the connection to the database
		db.close
	end
	puts "Information updated successfully!"
end

def update_information
	# Open connection
	db = open_connection
	# Get user input
	print "Enter the barcode for the item you'd like to update: "
	barcode = gets.strip
	begin # Check if barcode exists
		check_item = db.query "SELECT * FROM #{$db_name} WHERE Barcode = #{barcode} LIMIT 1"
		if (check_item.num_rows == 1)
			begin # Prepare database query and execute it
				column = ""
				value = ""
				puts "Which would you like to update?"
				puts "1: Barcode"
				puts "2: Item Name"
				puts "3: Item Category"
				puts "4: Quantity"
				puts "5: Price"
				puts "6: Description"
				user_input = gets.strip
				case user_input
				when "1"
					column = "Barcode"
					puts "Enter Barcode: "
					value = gets.strip
				when "2"
					column = "ItemName"
					puts "Enter Item Name: "
					value = gets.strip
				when "3"
					column = "ItemCategory"
					puts "Enter Item Category: "
					value = gets.strip
				when "4"
					column = "Quantity"
					puts "Enter Quantity: "
					value = gets.strip
				when "5"
					column = "Price"
					puts "Enter Price: "
					value = gets.strip
				when "6"
					column = "Description"
					puts "Enter Description: "
					value = gets.strip
				else
					puts "You did not enter a correct option."
				end
				if (column != "" && value != "")
					update_item = db.prepare "UPDATE #{$db_name} SET #{column} = ? WHERE Barcode = #{barcode}"
					update_item.execute value
					update_item.close
				end
			rescue # Catch any errors
				abort "There was an error updating item in the database. Please ensure that item exists."
			ensure # Close the connection to the database
				db.close
			end
		else
			abort "Barcode does not exist in the database."
		end
	end
	puts "Information updated successfully!"
end

# This function displays the home screen for the application
def home_screen
	puts "Welcome to the Ruby/MySQL Inventory Application!"
	puts "What would you like to do?"
	puts "1: List Database Contents"
	puts "2: Enter New Item Into Database"
	puts "3: Remove Item From Database"
	puts "4: Update Item Information"
	user_choice = gets.strip
	case user_choice
	when "1"
		display_contents
	when "2"
		add_information
	when "3"
		delete_information
	when "4"
		update_information
	else
		puts "You entered an incorrect option."
	end
end


home_screen