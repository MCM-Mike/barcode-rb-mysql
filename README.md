Ruby Barcode and Inventory Application Using MySQL
==================================================

This is a simple application that uses Ruby v2.0.0 to connect to a local MySQL database and to retrieve, update, add, and delete information from the database.

Requirements
------------

To use this application you must have MySQL installed and running on your machine. Included is a .sql file to populate the database with the information and setup needed. You must also install the mysql gem for ruby.

Using the Application
---------------------

When the application begins, the user is prompted for the information needed to connect to the database. This includes hostname, username, password, database, and table names. If the database or table do not exist the user is given the option to create them, and populate the table with sample data if they'd like.

The <code>sample_data.csv</code> file holds the sample data and the filename of this file is stored in a global variable at the top of <code>inventory.rb</code>.

After entering the information, the user is given a menu with options:
<pre>+---------------------------------------
|  What would you like to do?
|  1: List Database Contents
|  2: Enter New Item Into Database
|  3: Remove Item From Database
|  4: Update Item Information
|  5: Exit
|</pre>

From here, they can list the contents, add an item, remove an item, update an item, or exit. This concludes the basic functionality of the application.