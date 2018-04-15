#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use lib '.';
use Table;

my $table = Table->new({
	title => "FooBarBaz\n\n\tSome FOO\n\tSome BAR\n\tSome BAZ\n\n",
	columns => [
		{name => 'A', width => 20, align => Table::LEFT},
		{name => 'B', width => 30, align => Table::RIGHT},
		{name => 'C', width => 40, align => Table::CENTER},
	]
});

$Table::HRULE_CHAR = '=';

print $table->render(
	['foo', 'bar', 'baz'],
	['a' x (20 * 3 + 3), 'b' x (30 * 4 + 7), 'c' x (40 * 20 + 8)],
);
