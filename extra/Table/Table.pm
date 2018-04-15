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

sub new {
	my $class = shift;
	my $self = shift;

	return bless $self, $class;

}

sub render {
	my $self = shift;

	my $str;

	$str .= $self->_title() . $self->_header();

	for my $i (0 .. $#_) {
		$str .= $self->_row(@{$_[$i]});
	}
	return $str;
}

sub _title {
	my $self = shift;
	return $self->{title};
}

sub _header {
	my $self = shift;

	my @fields;
	for my $i (0 .. $#{$self->{columns}}) {
		push @fields, $self->{columns}[$i]{name};
	}

	return $self->_row(@fields);
}

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

sub _align {
	my ($str, $width, $align) = @_;
	return sprintf "%$align*s", $width, $str;
}

sub _left {
	my ($str, $width) = @_;
	return _align $str, $width, _ALIGN_LEFT;
}

sub _right {
	my ($str, $width) = @_;
	return _align $str, $width, _ALIGN_RIGHT;
}

sub _center {
	my ($str, $width) = @_;

	my $lw = ($width - length($str)) / 2;
	my $rw = int $lw;

	if ($lw - int $lw) {
		$rw += 1;
	}

	return ' ' x $lw . $str . ' ' x $rw;
}

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
