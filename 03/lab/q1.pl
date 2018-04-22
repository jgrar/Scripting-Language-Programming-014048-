#!/usr/bin/env perl
# Author: Jonathen Russell <s3547998>

use strict;
use warnings;
use utf8;

use Data::Dumper;

=item hasduplicates(@input)

Takes a list of values and returns a true value if there is any duplicated items
in the input. False if there aren't.

Adapted from:
https://stackoverflow.com/questions/4192724/algorithm-to-find-duplicate-in-an-array

=cut

sub hasduplicates {

	my @input = sort @_;

	# loop from 0 .. n - 2 to avoid overrun
	for my $i (0 .. $#input - 1) {
		if ($input[$i] eq $input[$i + 1]) {
			return 1;
		}
	}

	return 0;
}

=item duplicates1(@input)

Takes a list of values and returns the list of values which were duplicated in the
input. Uses array features.

=cut

sub duplicates1 {

	my @dupes = sort @_;

	for (my $i = 0; $i < @dupes; ) {
		my $j = $i + 1;

		# calculate the number of duplicates
		while ($j < @dupes and $dupes[$i] eq $dupes[$j]) {
			$j++;
		}

		if ($j - $i > 1) {
			$i++;
			splice @dupes, $i, $j - $i; # remove run of duplicates
		} else {
			splice @dupes, $i, 1; # remove the item, not a dupe
		}
	}

	return @dupes;
}

=item duplicates2(@input)

Takes a list of values and returns a hash of the values as keys and counts of
how many times it was seen in the input. Uses hash features.

=cut

sub duplicates2 {

	my %seen = ();

	for my $item (@_) {
		$seen{$item}++;
	}

	return %seen;
}

=item runtests(@input)

Perform a Data::Dumper->Dump on the subroutines in this script.

=cut

sub runtests {
	print Data::Dumper->Dump([
			hasduplicates(@_),
			[duplicates1(@_)],
			{duplicates2(@_)}
		],
		[qw(hasdupes dupes counts)]
	);
}

#=item simple test

runtests(qw(foo bar baz bar foo zorg));

#=cut

=item test with space-separated stdin values

while (<>) {
	chomp;
	runtests(split);
}

=cut
