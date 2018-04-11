#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Data::Dumper;
use Text::CSV;

use constant {
	NFIELDS => 4,

	ALIGN_LEFT => '-',
	ALIGN_RIGHT => '',

	FORMAT => [
		{fmt => \&left,  width => 24, header => "Item"    },
		{fmt => \&right, width => 12, header => "No."     },
		{fmt => \&right, width => 12, header => "Revenue" },
	],

	ITEM => 2,
	COST => 3,
};

my $csv;
BEGIN {
	$csv = Text::CSV->new();
}

sub trim {
	my $n;
	for my $i (0 .. $#_) {
		$n += $_[$i] =~ s/^\s+|\s+$//g;
	}
	return $n;
}

sub readsale {

	READ: $_ = <>;

	unless (defined) {
		return;
	}

	chomp;

	unless ($csv->parse($_)) {
		warn "warning: parse error: " . $csv->error_input() . "\n";
		goto READ;
	}

	my @fields = $csv->fields();

	unless (@fields == NFIELDS) {
		warn "warning: incorrect number of fields: $ARGV:$. $_\n";
		goto READ;
	}

	trim @fields;

	return ($fields[ITEM], $fields[COST]);
}

sub readsales {
	my %sales = ();

	unshift(@ARGV, '-') unless @ARGV;

	while (my ($item, $cost) = readsale) {
		unless (exists $sales{$item}) {
			$sales{$item} = [ $cost ];
		} else {
			push @{$sales{$item}}, $cost;
		}
	}

	return %sales;
}

sub align ($$$) {
	my ($str, $width, $align) = @_;

	return sprintf "%$align*.*s", $width, $width, $str;
}

sub left ($$) {
	my ($str, $width) = @_;
	return align($str, $width, ALIGN_LEFT);
}

sub right ($$) {
	my ($str, $width) = @_;
	return align($str, $width, ALIGN_RIGHT);
}

sub hrule (@) {
	my @cols = @_;

	my $str;
	for my $i (0 .. $#cols) {
		$str .= "=" x ($cols[$i]->{width});
	}
	$str .= "\n";

	return $str;
}

sub header (@) {

	my $str;
	for my $col (@_) {
		$str .= $col->{fmt}->($col->{header}, $col->{width});
	}
	$str .= "\n";
	$str .= hrule @_;

	return $str;

}

sub sum (@) {
	my $sum;
	map { $sum += $_ } @_;
	return $sum;
}

sub columns (\@@) {
	my ($cols, @fields) = @_;

	my $str;
	for my $i (0 .. $#{$cols}) {
		$str .= $cols->[$i]{fmt}->($fields[$i], $cols->[$i]{width});
	}
	$str .= "\n";
}

sub displaysales (\%@) {

	my ($sales, @cols) = @_;

	print header(@cols);

	for my $item (sort keys %{$sales}) {
		print columns(@cols,
			$item, scalar @{$sales->{$item}}, sum(@{$sales->{$item}})
		);
	}
}

sub main {
	displaysales %{{readsales}}, @{(FORMAT)};
}

&main;
