#!/Users/Casey/.rvm/rubies/ruby-2.0.0-rc1/bin/ruby
require 'rubygems'
require 'mysql'
begin
	require 'highline/import'
rescue
	puts "You do not have the highline gem installed, password will be shown in plain text."
end

$sample_data_filename = "./sample_data.csv"
# $db_hostname = 'localhost'
# $db_user = 'root'
# $db_pass = 'root'
# $db_name = 'inventory'
# $db_table_name = 'inventory'

# This function opens a connection to the database
def open_connection
	begin
		db = Mysql.new($db_hostname, $db_user, $db_pass)
	rescue Mysql::Error
		abort "Oops! Couldn't connect to database! Make sure you entered the correct information."
	end
	return db
end

# This function displays the contents of the database
def display_contents
	# Open connection
	db = open_connection
	begin
		# Set results equal to the result of the MySQL query
		results = db.query "SELECT * FROM #{$db_name}.#{$db_table_name}"
		puts "Number of items: #{results.num_rows}"

		puts "+----------------+---------------------------------+-----------------+----------+---------+-----------------------------+"
		puts "| Barcode".ljust(17) + "| Item Name:".ljust(34) + 
			"| Item Category".ljust(18) + "| Quantity".ljust(11) + 
			"| Price".ljust(10) + "| Description".ljust(29) + " |"
		puts "+----------------+---------------------------------+-----------------+----------+---------+-----------------------------+"
		# Loop through the results and output the data
		results.each_hash do |item|
			print "| #{item['Barcode']}".ljust(17)
			print "| #{item['ItemName']}".ljust(34)
			print "| #{item['ItemCategory']}".ljust(18)
			print "| #{item['Quantity']}".ljust(11)
			print "| #{item['Price']}".ljust(10)
			print "| #{item['Description']}".ljust(29) + " |"
			print "\n"
		end
		puts "+----------------+---------------------------------+-----------------+----------+---------+-----------------------------+"
		results.free
	rescue
		abort "Could not retrieve information from database. Ensure that table name has been entered properly."
	ensure
		db.close
	end
	home_screen
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
		insert_new_item = db.prepare "INSERT INTO #{$db_name}.#{$db_table_name} (Barcode, ItemName, ItemCategory, Quantity, Price, Description) VALUES (?, ?, ?, ?, ?, ?)"
		insert_new_item.execute barcode,item_name,item_category,quantity,price,description
		insert_new_item.close
	rescue # Catch any errors
		abort "There was an error adding information into the database."
	ensure # Close the connection to the database
		db.close
	end
	puts "Information added successfully!"
	home_screen
end

# This function allows the user to delete information from the database
def delete_information
	# Open connection
	db = open_connection
	# Get user input
	print "Enter the barcode for the item you'd like to delete: "
	barcode = gets.strip
	begin # Check if barcode exists
		delete_item = db.prepare "DELETE FROM #{$db_name}.#{$db_table_name} WHERE Barcode = ?"
		delete_item.execute barcode
		delete_item.close
	rescue # Catch any errors
		abort "There was an error deleting item from the database. Please ensure that item exists."
	ensure # Close the connection to the database
		db.close
	end
	print "Information deleted successfully!\n"
	home_screen
end

def update_information
	# Open connection
	db = open_connection
	# Get user input
	print "Enter the barcode for the item you'd like to update: "
	barcode = gets.strip
	begin # Check if barcode exists
		check_item = db.query "SELECT * FROM #{$db_name}.#{$db_table_name} WHERE Barcode = #{barcode} LIMIT 1"
		if (check_item.num_rows == 1)
			begin # Prepare database query and execute it
				column = ""
				value = ""
				print "\n+---------------------------------------\n"
				puts "|  Which would you like to update?"
				puts "|  1: Barcode"
				puts "|  2: Item Name"
				puts "|  3: Item Category"
				puts "|  4: Quantity"
				puts "|  5: Price"
				puts "|  6: Description"
				puts "|  7: Return to home screen"
				print "|  "
				user_input = gets.strip
				case user_input
				when "1"
					column = "Barcode"
					print "Enter Barcode: "
					value = gets.strip
				when "2"
					column = "ItemName"
					print "Enter Item Name: "
					value = gets.strip
				when "3"
					column = "ItemCategory"
					print "Enter Item Category: "
					value = gets.strip
				when "4"
					column = "Quantity"
					print "Enter Quantity: "
					value = gets.strip
				when "5"
					column = "Price"
					print "Enter Price: "
					value = gets.strip
				when "6"
					column = "Description"
					print "Enter Description: "
					value = gets.strip
				when "7"
					home_screen
				else
					puts "You did not enter a correct option."
				end
				if (column != "" && value != "")
					update_item = db.prepare "UPDATE #{$db_name}.#{$db_table_name} SET #{column} = ? WHERE Barcode = #{barcode}"
					update_item.execute value
					update_item.close
					check_item = db.query "SELECT * FROM #{$db_name}.#{$db_table_name} WHERE Barcode = #{barcode} LIMIT 1"
					print "\n"
					check_item.each_hash do |item|
						puts "Barcode: #{item['Barcode']}"
						puts "Item Name: #{item['ItemName']}"
						puts "Item Category: #{item['ItemCategory']}"
						puts "Quantity: #{item['Quantity']}"
						puts "Price: #{item['Price']}"
						puts "Description: #{item['Description']}"
						print "\n"
					end
				end
			rescue # Catch any errors
				puts "There was an error updating item in the database. Please ensure that item exists."
				home_screen
			ensure # Close the connection to the database
				db.close
			end
		else
			puts "Barcode does not exist in the database."
			home_screen
		end
	end
	puts "Information updated successfully!"
	home_screen
end

# This function displays the home screen for the application and receives user choice
def home_screen
	print "\n+---------------------------------------\n"
	puts "|  What would you like to do?"
	puts "|  1: List Database Contents"
	puts "|  2: Enter New Item Into Database"
	puts "|  3: Remove Item From Database"
	puts "|  4: Update Item Information"
	puts "|  5: Exit"
	print "|  "
	user_choice = gets.strip
	print "\n"
	case user_choice
	when "1"
		display_contents
	when "2"
		add_information
	when "3"
		delete_information
	when "4"
		update_information
	when "5"
		abort "Goodbye!"
	else
		puts "You entered an incorrect option."
		home_screen
	end
end

# This function loads the sample data from the global $sample_data_filename
def load_sample_data
	begin # try to load the file
		# open the file and create an array to hold it
		sample_data_file = File.open($sample_data_filename)
		sample_contents = Array.new{Array.new}
		i = 0
		# add the contents of the file to the two-dimensional array
		sample_data_file.each do |line|
			sample_contents[i] = line.split(",").map(&:strip)
			i += 1
		end
		return sample_contents
	rescue # catch exceptions
		abort "Unable to continue - sample data file #{$sample_data_filename} not found."
	end
end



#------- MAIN APPLICATION -------#


puts "Welcome to the Ruby/MySQL Inventory Application!"

# Prompt for database information
print "Enter Database Hostname: "
$db_hostname = gets.strip
print "Enter Username: "
$db_user = gets.strip
begin # Use highline gem to blank password if available
	$db_pass = ask("Enter password: ") { |q| q.echo = false}
rescue # If not, just show password
	print "Enter Password: "
	$db_pass = gets
end
db = open_connection
puts "Database connection successful!"
print "Enter Database Name: "
$db_name = gets.strip

# Check if the database exists, and ask the user if they'd like to create it if it doesn't
check_database = db.query "SHOW DATABASES LIKE '#{$db_name}'"
if (check_database.num_rows > 0)
	# Use the database if it exists
	db.query "USE #{$db_name}"
else
	user_choice = ""
	loop do # Ask the user if they'd like to create the database
		print "Database does not exist, would you like to create it? (requires permissions) Y/N: "
		user_choice = gets.strip.upcase
		break if (user_choice == "Y" || user_choice == "N")
	end
	if (user_choice == "Y")
		begin # If yes, try to create the database and select it
			db.query "CREATE DATABASE #{$db_name}"
			db.query "USE #{$db_name}"
		rescue # catch any errors
			abort "An error has occurred. Unable to create database"
		end
		puts "Database successfully created!"
	elsif (user_choice == "N")
		abort "Goodbye!" # Exit the program
	end
end

# Prompt for table name
print "Enter the name of your table: "
$db_table_name = gets.strip

# Check if table exists
check_table = db.query "SHOW TABLES LIKE '#{$db_table_name}'"
if (check_table.num_rows > 0)
	db.close # If it does, close connection and open the home screen
	home_screen
else # If it does not, ask the user if they'd like to create it
	user_choice = ""
	loop do
		print "Table does not exist in database, would you like to create it? (requires permissions) Y/N: "
		user_choice = gets.strip.upcase
		break if (user_choice == "Y" || user_choice == "N")
	end
	if (user_choice == "Y")
		begin # If yes, create the table with the appropriate columns
			db.query("CREATE TABLE IF NOT EXISTS #{$db_table_name} ( \
				Barcode varchar(20) NOT NULL, \
				ItemName varchar(40) NOT NULL, \
			  	ItemCategory varchar(20) NOT NULL, \
			  	Quantity int(11) NOT NULL, \
			  	Price float NOT NULL, \
			  	Description varchar(40) NOT NULL, \
			  	UNIQUE KEY Barcode (Barcode) \
			) ENGINE=MyISAM DEFAULT CHARSET=utf8;")
		rescue Mysql::Error => e
			puts e
		end
		puts "Table successfully created!"
		loop do # Ask the user if they'd like to populate the table
			print "Would you like to populate with sample data? (requires permissions) Y/N: "
			user_choice = gets.strip.upcase
			break if (user_choice == "Y" || user_choice == "N")
		end
		if (user_choice == "Y") # If yes, load the data and populate the table
			sample_data = load_sample_data
			begin # Loop through the data and insert each row
			sample_data.each do |a|
				db.query("INSERT INTO #{$db_table_name} ( \
					`Barcode`, `ItemName`, `ItemCategory`, `Quantity`, `Price`, `Description` \
					) VALUES ( \
					'#{a[0]}', '#{a[1]}', '#{a[2]}', #{a[3]}, #{a[4]}, '#{a[5]}')")
			end
			rescue Mysql::Error => e # Catch any errors
				puts "Could not populate table."
				puts e
			end
		end
		puts "Table populated successfully!"
		db.close # Close the connection and display home screen
		home_screen
	elsif (user_choice == "N")
		abort "Goodbye!"
	end	
end
db.close