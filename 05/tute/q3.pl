#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Data::Dumper;

use Text::CSV;

my $csv;
BEGIN {
	$csv = Text::CSV->new();
}

# trim - remove spaces from the left and right
sub trim {

	my $n;

	for my $i (0 .. $#_) {
		$n += $_[$i] =~ s/^\s+|\s+$//g
	}

	return $n;
}

# wwrap - wrap text on a word boundary to fit len
sub wwrap ($@) {
	my $len = shift;
	my $n = 0;

	for my $i (0 .. $#_) {
		
		my $str = $_[$i];
		my @lines;

		while ($len < length($str)) {

			my $line = substr($str, 0, $len);

			my $z = rindex($line, ' ');

			if ($z == -1) {
				$z = $len;
			} else {
				$line = substr($str, 0, $z);
				$z += 1;
			}
			push @lines, $line;
			$str = substr($str, $z);
		}
		push @lines, $str;
		
		$n = @lines if (@lines > $n);

		$_[$i] = \@lines;
	}
	return $n;
}

use constant {
	ALIGN_LEFT => '-',
	ALIGN_RIGHT => '',
};

sub align ($$$) {
	my ($str, $width, $align) = @_;
	return sprintf "%$align*s", $width, $str;
}

# left - align text to the left padded with spaces to width
sub left ($$) {
	my ($str, $width) = @_;
	return align $str, $width, ALIGN_LEFT;
}

# right - align text to the right padded with spaces to width
sub right ($$) {
	my ($str, $width) = @_;
	return align $str, $width, ALIGN_RIGHT;
}

# center - align text in the center padded with spaces on the left and right
sub center ($$) {
	my ($str, $width) = @_;

	my $lpad = ($width - length($str)) / 2;

	my $rpad = int $lpad;

	# can't center in the middle of a glyph, shift it over by 1
	if ($lpad - int $lpad) {
		$rpad += 1;
	}
	return " " x $lpad . $str . " " x $rpad;
}

# hrule - returns a horizontal rule for a table, takes an array of hash
# reference column specifiers, see columns() and displayCSV()
sub hrule (@) {
	my @cols = @_;

	my $str;
	for my $i (0 .. $#cols) {
		$str .= "+-" . "-" x ($cols[$i]->{width}) . "-+";
	}
	$str .= "\n";

	return $str;
}

# columns - takes an array of column specifier hash references of the form:
#
# (
# 	{fmt => \&sub, width => x, field => "..." }
# 	{ ... }
# )
#
# wraps field on word boundary to fit width and formats according to fmt,
# each field wraps inside it's own column. Returns a string.
sub columns (\@@) {

	my ($cols, @fields) = @_;

	my $nrows = 0; # amount of rows to print

	# wrap each column into rows, find the maximum amount of rows
	for my $i (0 .. $#{$cols}) {

		my $n = wwrap($cols->[$i]{width}, $fields[$i]);
		$nrows = $n if ($n > $nrows);
	}

	my $str; # result string

	# loop to the deepest field row
	for my $i (0 .. $nrows - 1) {

		for my $j (0 .. $#{$cols}) {

			# put a empty string in undef field rows
			unless (defined $fields[$j][$i]) {
				$fields[$j][$i] = "";
			}

			# format the field, add it to the result string
			$str .= sprintf "| %s |",
				$cols->[$j]{fmt}->($fields[$j][$i], $cols->[$j]{width});
		}
		$str .= "\n";
	}
	$str .= hrule @{$cols};
	return $str;
}

# header - returns header formatted fields for a CSV table, takes an array of
# hash reference column specifiers, see columns() and displayCSV()
sub header ($\@@) {
	my ($file, $cols, @fields) = @_;
	my $str;

	$str .= "$file:\n";
	$str .= hrule @{$cols};

	for my $i (0 .. $#{$cols}) {
		$str .= sprintf "| %s |",
			$cols->[$i]{fmt}->($fields[$i], $cols->[$i]{width});
	}
	$str .= "\n";
	$str .= hrule @{$cols};

	return $str;
}

# readfields - read csv fields from a file, returns a list of fields
sub readfields ($) {

	my ($fh) = @_;
	local $_;

	READ: $_ = <$fh>;

	unless (defined) {
		return;
	}

	chomp;

	unless ($csv->parse($_)) {
		warn "warning: parse error: " . $csv->error_input() . "\n";
		goto READ;
	}

	my @fields = $csv->fields();

	trim @fields;

	return @fields;
}

# readCSV - read a csv file with specific number of columns. Returns a data
# structure like the following:
# (
# 	headers => [ ... ]
# 	fields => [
# 		[ ... ],
# 		[ ... ],
# 	]
# )
sub readCSV ($$) {
	my ($file, $ncols) = @_;

	my %data = (
		headers => [],
		fields => [],
	);

	my $fh;

	unless (open $fh, $file) {
		warn "warning: failed to open '$file': $!\n";
		return;
	}

	## read header fields
	unless ($data{headers} = [readfields($fh)]) {
		warn "warning: failed to read headers '$file': $!\n";
		return;
	}

	# validate number of fields
	unless (@{$data{headers}} == $ncols) {
		warn "warning: number of fields doesn't match column specification\n";
		return;
	}

	# read the rest of the fields
	while (my @fields = readfields $fh) {

		unless (@fields == $ncols) {
			warn "warning: number of fields doesn't match column specification\n";
			next;
		}

		push @{$data{fields}}, [ @fields ];
	}

	return %data;
}

# displayCSV - formatted printing of CSV files, takes a filename and a column
# specifier array of the form:
# (
# 	{ fmt => \&sub, width => x },
# 	{ ... }
# )
# where fmt is one of left(), right() or center() and width is the desired
# column width
sub displayCSV ($@) {

	my ($file, @cols) = @_;

	my %data;

	unless (%data = readCSV($file, scalar @cols)) {
		return;
	}

	print header($file, @cols, @{$data{headers}});

	for my $i (0 .. $#{$data{fields}}) {
		print columns(@cols, @{$data{fields}[$i]});
	}
	print "\n";
}

use constant FORMAT => [
	{ fmt => \&left,   width => 20 },
	{ fmt => \&right,  width => 10 },
	{ fmt => \&center, width => 40 },
];

sub main {

	# mimics behaviour of `while (<>) ...` see perldoc -f '<>'
	unshift (@ARGV, '-') unless @ARGV;

	while (my $arg = shift @ARGV) {
		displayCSV($arg, @{(FORMAT)});
	}
}

&main;

