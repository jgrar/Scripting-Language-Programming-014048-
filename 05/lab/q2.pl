#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Data::Dumper;

use constant {
	NAME  => qr/\b[A-Za-z'!. ]+\b/,
	MARK  => qr/100|[1-9]\d?(?:\.\d?[1-9])?/,
	DELIM => ':',
};

sub readgrade {

	my @fields;

	READ: $_ = <>;

	unless (defined) {
		return;
	}

	chomp;

	@fields = /^(${\NAME})${\DELIM}(${\MARK})$/;

	unless (@fields) {
		warn "warning: parse error $ARGV:$. $_\n";
		goto READ;
	}

	return @fields;
}

use constant {
	MAX_GRADES => 5,
};

sub addgrade (\%%) {
	my ($master, %grades) = @_;

	for my $student (keys %grades) {

		unless (defined($master->{$student})) {
			$master->{$student} = [];

		} elsif (@{$master->{$student}} == MAX_GRADES) {
			warn "warning: student exceeds maximum classes: $student\n";
			return;
		}
		push @{$master->{$student}}, $grades{$student};
	}
}

sub readgrades {
	my %grades = ();

	unshift(@ARGV, '-') unless @ARGV;

	while (my ($name, $mark) = readgrade) {
		addgrade(%grades, $name, $mark);
	}
	return %grades;
}

use constant {
	LEFT  => '',
	RIGHT => '-',
};

sub align ($$$) {
	my ($str, $width, $align) = @_;

	return sprintf "%$align*.*s", $width, $width, $str;
}

sub left ($$) {
	return align $_[0], $_[1], LEFT;
}

sub right ($$) {
	return align $_[0], $_[1], RIGHT;
}

sub hrule (@) {
	my @cols = @_;

	my $str;
	for my $i (0 .. $#cols) {
		$str .= "=" x ($cols[$i]{width});
	}
	$str .= "\n";

	return $str;
}

sub columns (\@@) {

	my ($cols, @fields) = @_;

	my $str;
	for my $i (0 .. $#{$cols}) {
		$str .= $cols->[$i]{fmt}->($fields[$i], $cols->[$i]{width});
	}
	$str .= "\n";
}

sub header (@) {
	my $str;

	for my $col (@_) {
		$str .= $col->{fmt}->($col->{header}, $col->{width});
	}
	$str .= "\n";
	$str .= hrule(@_);

	return $str;
}

sub average (@) {
	my $sum;
	map { $sum += $_ } @_;
	return (@_) ? $sum / @_ : 0;
}

sub displaygrades (\%@) {
	my ($grades, @cols) = @_;

	print header(@cols);

	for my $student (sort keys %{$grades}) {
		print columns(@cols, $student, average(@{$grades->{$student}}));
	}
}

use constant FORMAT => [
	{ fmt => \&left,  width => 24, header => "Name"         },
	{ fmt => \&right, width => 12, header => "Average Mark" },
];

sub main {
	displaygrades %{{readgrades}}, @{(FORMAT)};
}

&main;

