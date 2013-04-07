#!/Users/Casey/.rvm/rubies/ruby-2.0.0-rc1/bin/ruby
require 'rubygems'
require 'mysql'

# connection = File.read("connection.txt").split(",").map(&:strip)
def open_connection
	begin
		db = Mysql.new('localhost', 'root', '', 'inventory')
	rescue Mysql::Error
		puts "Oops! Couldn't connect to database!"
	end
	puts "Connection successful!"
	return db
end

def display_help
	# define the help variable which holds the help text
	help = "Usage: ruby inventory.rb [?|-h|help|[-u|-o|-z <infile>|[<outfile>]]]\nParameters:
   ?                     displays this usage information
   -h                    displays this usage information
   help                  displays this usage information
   -u <infile>           update the inventory using the file <infile>.
                         The filename <infile> must have a .csv
                         extension and it must be a text file in comma
                         separated value (CSV) format. Note that the
                         values must be in double quote.
   -z|-o [<outfile>]     output either the entire content of the
                         database (-o) or only those records for which
                         the quantity is zero (-z). If no <outfile> is
                         specified then output on the console otherwise
                         output in the text file named <outfile>. The
                         output in both cases must be in a tab separated
                         value (tsv) format."
	# print the help screen
	puts help
end # display_help

db = open_connection()
# if argument is ?, -h, or help, display the help screen
if (ARGV[0] == "?" or ARGV[0] == "-h" or ARGV[0] == "help")
	display_help
# if it is -u, call the update_inventory function
elsif (ARGV[0] == "-o")
	begin
		results = db.query "SELECT * FROM inventory"
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