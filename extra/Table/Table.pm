package Table;

use strict;
use warnings;

use constant {
	LEFT   => \&_left,
	RIGHT  => \&_right,
	CENTER => \&_center,
};

our $HRULE_CHAR = '-';
our $HRULE_FIELD_LEFT  = '+-';
our $HRULE_FIELD_RIGHT = '-+';

our $FIELD_LEFT  = '| ';
our $FIELD_RIGHT = ' |';

# set the configuration for a new table
sub new {
	my $class = shift;
	my $self = shift;

	return bless $self, $class;

}

# render the table into a string
sub render {
	my $self = shift;

	my $str;

	$str .= $self->_title() . "\n" . $self->_header();

	for my $i (0 .. $#_) {
		$str .= $self->_row(@{$_[$i]});
	}
	return $str;
}

# get the title for the table
sub _title {
	my $self = shift;
	return $self->{title};
}

# render the column name fields into a string of columns
sub _header {
	my $self = shift;

	my @fields;
	for my $i (0 .. $#{$self->{columns}}) {
		push @fields, $self->{columns}[$i]{name};
	}

	return $self->_row(@fields);
}

# render a horizontal rule that fits the table column field widths
sub _hrule {
	my $self = shift;
	my $str;

	for my $i (0 .. $#{$self->{columns}}) {
		$str .= $HRULE_FIELD_LEFT;
		$str .= $HRULE_CHAR x ($self->{columns}[$i]{width});
		$str .= $HRULE_FIELD_RIGHT;
	}
	return $str . "\n";
}

# render a row of table field data, word wrapping each field with a horizontal
# rule delmiting the end as a string
sub _row {
	my $self = shift;
	my @fields = @_;
	my $str;

	my $nrows = 0;

	for my $i (0 .. $#fields) {
		my $n = _wrap($self->{columns}[$i]{width}, $fields[$i]);
		$nrows = $n if $n > $nrows;
	}

	for my $i (0 .. $nrows - 1) {
		for my $j (0 .. $#{$self->{columns}}) {

			$fields[$j][$i] = '' unless defined $fields[$j][$i];

			$str .= $FIELD_LEFT;
			$str .= $self->{columns}[$j]{align}->(
				$fields[$j][$i],
				$self->{columns}[$j]{width}
			);
			$str .= $FIELD_RIGHT;
		}
		$str .= "\n";
	}
	return $str . $self->_hrule();
}

use constant {
	_ALIGN_RIGHT => '',
	_ALIGN_LEFT  => '-',
};

# render a string aligned to a specified alignment constrained by width
sub _align {
	my ($str, $width, $align) = @_;
	return sprintf "%$align*s", $width, $str;
}

# render a string left-aligned
sub _left {
	my ($str, $width) = @_;
	return _align $str, $width, _ALIGN_LEFT;
}

# render a string right-aligned
sub _right {
	my ($str, $width) = @_;
	return _align $str, $width, _ALIGN_RIGHT;
}

# render a string center-aligned
sub _center {
	my ($str, $width) = @_;

	# calculate the padding width for the left and right
	my $lw = ($width - length($str)) / 2;
	my $rw = int $lw;

	# if the width aligns to the middle of a glyph (.5) shift it by 1
	if ($lw - int $lw) {
		$rw += 1;
	}

	return ' ' x $lw . $str . ' ' x $rw;
}

# word wrap a list of arguments to a specified width, returns a list of list
# references where each list reference element is a row that has been wrapped
sub _wrap {
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

		$n = @lines if @lines > $n;

		$_[$i] = \@lines;
	}
	return $n;
}

1;

=head1 NAME

Table.pm

=head1 SYNOPSIS

	my $table = Table->new({
		title   => 'some title for my table!',
		columns => [
			{ title => 'Column A', width => 15, align => Table::LEFT   },
			{ title => 'Column B', width => 20, align => Table::CENTER },
			{ title => 'Column C', width => 32, align => Table::RIGHT  },
		],
	});

	# ...

	$table->render(['a' x 32, 'b' x 56, 'c' x 43], ['a' x 20, 'b' x 26, 'c' x 38]);


=head1 DESCRIPTION

Renders ascii tables to a specified format.

Columns fields are word wrapped within the column they are specified for.

=head1 EXAMPLE

	my $table = Table->new({
		title   => 'some title for my table!',
		columns => [
			{ title => 'Column A', width => 15, align => Table::LEFT   },
			{ title => 'Column B', width => 20, align => Table::CENTER },
			{ title => 'Column C', width => 32, align => Table::RIGHT  },
		],
	});

	# ...

	$table->render(['a' x 32, 'b' x 56, 'c' x 43], ['a' x 20, 'b' x 26, 'c' x 38]);

Outputs:

	some title for my table!
	| Column A        ||       Column B       ||                         Column C |
	+-----------------++----------------------++----------------------------------+
	| aaaaaaaaaaaaaaa || bbbbbbbbbbbbbbbbbbbb || cccccccccccccccccccccccccccccccc |
	| aaaaaaaaaaaaaaa || bbbbbbbbbbbbbbbbbbbb ||                      ccccccccccc |
	| aa              ||   bbbbbbbbbbbbbbbb   ||                                  |
	+-----------------++----------------------++----------------------------------+
	| aaaaaaaaaaaaaaa || bbbbbbbbbbbbbbbbbbbb || cccccccccccccccccccccccccccccccc |
	| aaaaa           ||        bbbbbb        ||                           cccccc |
	+-----------------++----------------------++----------------------------------+

