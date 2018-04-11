#!/usr/bin/env perl
# Author: Jonathen Russell <s3547998>

=head1 NAME

Find user passwd entry

=head1 SYNOPSIS

	./q2.pl [TERM [FILE]]

=head1 DESCRIPTION

Finds passwd entries that contain the term in the login or user name fields as a
substring and prints the full entry.

=head1 DEFAULTS

	TERM defaults to "smith"

	FILE defaults to "etc passwd file"

=over

=cut

use strict;
use warnings;
use utf8;

use constant {

	PASSWD_NUM_FIELDS => 7,
	ERROR_MALFORMED_FILE => "error: malformed passwd file",

	PASSWD_DELIM => ':',

	LOGIN_FIELD => 0,
	NAME_FIELD => 4,

	DEFAULT_TERM => "smith",
	DEFAULT_FILE => "etc passwd file",
};

=item findsubstr $term, LIST

Matches term against items of LIST as a substring. Returns a list of the
items that matched or false if none matched.

=cut

sub findsubstr ($@) {

	my ($term, @params) = @_;

	my @matches;

	for my $param (@params) {

		$param = lc $param;

		for my $i (0 ..  length($param) - length($term)) {

			if (substr($param, $i, length $term) eq $term) {
				push @matches, $param;
				last;
			}
		}
	}

	return @matches;
}

=item readentry $fh

Read and split an entry read from filehandle into a list of entries.

Returns the list of entry fields or false if a read error occurred, or eof or if
the entry isn't a valid passwd entry (does not have exactly 7 fields).

=cut

sub readentry {

	my ($fh) = @_;

	my $line;
	my @entry;

	if (defined($line = <$fh>)) {

		chomp $line;

		@entry = split PASSWD_DELIM, $line;

		if (@entry != PASSWD_NUM_FIELDS) {
			warn ERROR_MALFORMED_FILE, "\n";
			return;
		}
	}

	return @entry;
}

=item main $term $file

Opens the passwd file and searches entry login name and user name fields for a
substring match of term. Prints the full entries that match the term.

See findsubstr() and readentry().

=cut

sub main {

	my ($term, $file) = @_;

	open my $fh, $file
		or die "error: could not open '$file': $!\n";

	while (my @entry = readentry($fh)) {

		if (findsubstr $term, $entry[LOGIN_FIELD], $entry[NAME_FIELD]) {
			print join(PASSWD_DELIM, @entry), "\n";
		}
	}

	close $fh
		or warn "error: could not close handle for '$file': $!\n";
}


my $term = shift // DEFAULT_TERM;
my $file = shift // DEFAULT_FILE;

die "error: '$file' does not exist\n"
	if not -e $file;

main($term, $file);

=back

=head1 AUTHOR

Jonathen Russell <s3547998@student.rmit.edu.au>

=head1 COPYRIGHT

Copyright 2018 Jonathen Russell License MIT

=cut

