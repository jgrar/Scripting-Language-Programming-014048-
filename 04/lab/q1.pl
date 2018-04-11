#!/usr/bin/env perl
# Author: Jonathen Russell <s3547998>

use strict;
use warnings;
use utf8;

my $file = "input.txt";

open FILE, $file or die "Cannot open $file; $!";

my $line;
while ($line = <FILE>) {
	print $line;
}

=item *

Edit a file with anything: name it "input.txt"

=item *

Run this script, what does it do?

This script outputs whatever is in 'input.txt'

=item *

Make sure a file called "input.txt" does not exist

	Cannot open input.txt; No such file or directory

=item *

C<$!> contains error messages pertaining to the last error encountered
(mnemonic: BANG), in this case the fact that the file was not found.

=item *

if you remove the newline character off the end of the die text, it appends onto
the die message the line number the die command lives on in the source code (try
it yourself!)

	Cannot open input.txt; No such file or directory at ./q1.pl line 10.

=item *

Make sure a file called "input.txt" does exist, but you cannot actually read it.
For example C<chmod 000 input.txt> What happens now? Check out the error
message.

	Cannot open input.txt; Permission denied at ./q1.pl line 10.

=cut

