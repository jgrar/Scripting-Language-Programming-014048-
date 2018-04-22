#!/usr/bin/env perl
# Author: Jonathen Russell <s3547998>

use strict;
use warnings;
use utf8;

use Data::Dumper;

=item firstnonrepeating1($input)

Algorithm 1 for finding the first non-repeating character in a string.

Takes a string as input and returns the first non-repeating character or undef
if all characters repeat.

=cut

sub firstnonrepeating1 {

	my @input = split //, lc shift;
	my %seen = ();

	# count each item
	for my $item (@input) {
		$seen{$item}++;
	}

	# find first in sequence that was counted once
	for my $item (@input) {
		if ($seen{$item} == 1) {
			return $item;
		}
	}
	return undef;
}

=item firstnonrepeating2($input)

Algorithm 2 for finding the first non-repeating character in a string.

Takes a string as input and returns the first non-repeating character or undef
if all characters repeat.

=cut

sub firstnonrepeating2 {

	my @input = split //, lc shift;
	my %seen = ();

	SEARCH: for my $i (0 .. $#input) {

		# skip if it has been checked
		next if (exists $seen{$input[$i]});

		# sub-search using $input[$i] as the term
		for my $j (0 .. $#input) {

			# skip checking the same index
			next if ($j == $i);

			# add to seen list if the character repeats, restart
			if ($input[$i] eq $input[$j]) {
				$seen{$input[$i]}++;
				next SEARCH;
			}
		}

		# fall-through, current term doesn't repeat
		return $input[$i];
	}
	return undef;
}

=item runtests(@input)

Perform a Data::Dumper->Dump on the subroutines in this script.

=cut

sub runtests {

	print Data::Dumper->Dump([
			firstnonrepeating1($_[0]),
			firstnonrepeating2($_[0])
		],
		[qw(firstnonrepeating1 firstnonrepeating2)]
	);
}

#=item simple test

runtests("Proprietary order");

#=cut

=item test with stdin lines

while (<>) {
	chomp;
	runtests($_);
}

=cut
