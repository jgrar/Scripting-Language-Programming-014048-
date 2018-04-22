#!/usr/bin/env perl
# Author: Jonathen Russell <s3547998>

use strict;
use warnings;
use utf8;

=head1 Lab 3

=head2 Question 3

Write a small Perl script that will accept 3 items: An identification number for
something like customer ID, an "item description" and a price. Eg. the screen
should look like:

	Enter CustomerID: 12345
	Enter Item: Blank CD
	Enter Price: 2.95

=over

=item

All values are read from STDIN

=item

All 3 items along with a date of purchase, are to be written to a text file in
append mode.

=back

The file format should be "date,customer,item,price" (no spaces).

Don't worry about error checking for now. Code can either exit once entering in
one entry or be in a loop. If the latter, provide some exit code into Customer
ID to exit. We will build on this script in future labs. The date of purchase is
accessible by running the following code:

	# Perl also supports backquotes in the same way Bourne Shell does.
	my $date = `date +"%Y-%m-%d"`;
	
	# Alternatively if you want a purely Perl way of getting todays date:
	my @lt = localtime;
	# The month field is stored as a number between 0 and 11, add 1 to make
	# it normal.
	my $date = join("/", $lt[5] + 1900, $lt[4] + 1, $lt[3]);

=head2 Usage

Launch the program and enter customer ID, item description and price. Program
will loop to a new item unless "quit" is entered as the Customer ID. Writes
sales information to 'sales.txt'

=head3 Example

	$ perl q3.pl
	Enter CustomerID (or enter 'quit' to exit): 12345
	Enter Item: Blank disc
	Enter Price: 2.50
	Enter CustomerID (or enter 'quit' to exit): quit

=cut

open FH, ">>",  "sales.txt";

for (;;) {
	print "Enter CustomerID (or enter 'quit' to exit): ";
	my $customer = <>;
	chomp $customer;

	last if ($customer eq "quit");

	print "Enter Item: ";
	my $item = <>;
	chomp $item;

	print "Enter Price: ";
	my $price = <>;
	chomp $price;

	my @lt = localtime;
	my $date = join("-", $lt[5] + 1900, $lt[4] + 1, $lt[3]);

	print FH "$date,$customer,$item,$price\n"
}

close(FH);
