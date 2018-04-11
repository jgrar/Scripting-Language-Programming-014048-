#!/usr/bin/env perl
# Author: Jonathen Russell <s3547998>

=head1 NAME

Sales entry system

=head1 DESCRIPTION

Prompts the user for sales entries (customer, item and price) on a loop. Users
can enter 'quit' (case insensitive) as the customer id or press CTRL+D at any
time to quit the program. All sales entered are appended to a CSV file called
"sales.txt".

=over

=cut

use strict;
use warnings;
use utf8;

use constant {

	QUIT_CMD => 'quit',

	SALES_FILE  => 'sales.txt',
	CSV_DELIM => ',',
};

=item squash LIST

Squashes whitespace characters in argument list by transliterating extraneous whitespace
into one of that same whitespace character. Returns the number of characters transliterated.

=cut

sub squash {

	my $n;
	for my $i (0 .. $#_) {
		$n += $_[$i] =~ tr/ \t\r\n\f//s
	}
	return $n;
}

=item trim LIST

Trims leading and trailing white space from arguments and returns the number of
groups of white space removed. Works like chomp and does the same job too.

=cut

sub trim {

	my $n;

	for my $i (0 .. $#_) {
		$n += $_[$i] =~ s/^\s+|\s+$//g;
	}

	return $n;
}

=item prompt $msg

Print a message argument and read a non-empty string from STDIN and return it.
Repeatedly prompts the user for correct input.

=cut

sub prompt ($) {

	my ($msg) = @_;
	my $line;

	for (print $msg; $line = <STDIN>; print $msg) {

		squash $line;
		trim $line;

		last if $line ne '';

		print "Input is empty, please try again.\n";
	}

	return $line;
}

=item isprice LIST

Validates input list as valid monetary values.

Valid monetary values are digits seperated by a '.' (dot), with exactly two
digits in the decimal place representing cents. Only one leading zero is
permitted if the value represents non-zero cents only. e.g.

	"0.90" is valid for 90 cents

	"01.20" would be invalid, as would "1.200" due to unnecessary zeroes

	"1.00" would be valid for 1 dollar

	"0.00" is invalid

Returns true if all arguments validate, false if at least one does not validate.

=cut

sub isprice {

	for my $i (0 .. $#_) {
		return unless (
			$_[$i] =~ /^(0|([1-9]\d*))\.\d{2}$/ and
			$_[$i] !~ /^0\.00$/
		);
	}

	return 1;
}

=item promptprice $msg

Prompts the user for valid monetary value input.

See isprice() and prompt().

=cut

sub promptprice ($) {

	my ($msg) = @_;

	while (my $line = prompt($msg)) {

		return $line if isprice($line);

		print "Input isn't a valid price, please try again.\n";
	}

	return;
}

=item getdate

Returns todays date in the form YYYY-MM-DD.

=cut

sub getdate {

	my @lt = localtime;
	return sprintf("%d-%02d-%02d", $lt[5] + 1900, $lt[4] + 1, $lt[3]);
}

=item readsale

Reads a sale entry from the user by prompting for customer id, item, and price.
Input cannot be empty and must be valid, users are repeatedly prompted for valid
input if a value fails validation.

To cancel the sales prompts the user can enter 'quit' (case-insensitive) as the
customer id or press CTRL+D at any time.

Returns a list of the form "(date, customer, item, price)" or false if a read
failed.

=cut

sub readsale {

	my $customer = prompt "Enter CustomerID or 'quit' to exit: "
		or return;

	return if lc $customer eq QUIT_CMD;

	my $item = prompt "Enter Item: "
		or return;

	my $price = promptprice "Enter Price: "
		or return;

	return (getdate(), $customer, $item, $price);
}

=item writesale $fh, $date, $customer, $item, $price

Writes a sales entry list as comma-seperated values to the filehandle given as
the first argument. Returns false on write error or if the entry to be written
is empty.

=cut

sub writesale {

	my ($fh, @entry) = @_;

	return if not @entry;

	return print $fh join(CSV_DELIM, @entry), "\n";
}

=item main

Opens the sales file and prompts the user for sales input on a loop.

See prompt(), readsale() and writesale().

=cut

sub main {

	open my $oh, ">>", SALES_FILE
		or die "error: failed to open '", SALES_FILE, "': $!\n";

	while (writesale $oh, readsale()) {}

	close $oh
		or warn "warning: couldn't close output handle: $!\n";
}


main();

=back

=head1 AUTHOR

Jonathen Russell <s3547998@student.rmit.edu.au>

=head1 COPYRIGHT

Copyright 2018 Jonathen Russell License MIT

=cut

