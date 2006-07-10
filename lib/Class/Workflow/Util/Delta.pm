#!/usr/bin/perl

package Class::Workflow::Util::Delta;
use Moose;

use Carp qw/croak/;

use Data::Compare ();

has from => (
	does => "Class::Workflow::Instance",
	is   => "ro",
	required => 1,
);

has to => (
	does => "Class::Workflow::Instance",
	is   => "ro",
	required => 1,
);

has changes => (
	isa => "HashRef",
	is  => "ro",
	auto_deref => 1,
	lazy => 1,
	default => sub { $_[0]->_compute_changes },
);

sub BUILD {
	my $self = shift;

	croak "The instances must be of the same class"
		unless $self->from->meta->name eq $self->to->meta->name;
}

sub _compute_changes {
	my $self = shift;

	my %changes;

	my ( $from, $to ) = ( $self->from, $self->to );

	my @attrs = $from->meta->compute_all_applicable_attributes;

	# FIXME implies that accessors have been generated.. NOT NECESSARILY THE CASE
	foreach my $attr ( grep { $_->name !~ /^(?:prev|state|transition)$/ } @attrs ) {
		my $name = $attr->name;
		my $res = $self->_compare_values(
			$attr,
			$from->$name,
			$to->$name,
		);

		$changes{$name} = $res if $res;
	}

	return \%changes;
}

sub _compare_values {
	my ( $self, $attr, $from, $to ) = @_;

	unless ( Data::Compare::Compare( $from, $to ) ) {
		return { from => $from, to => $to };
	} else {
		return;
	}
}

__PACKAGE__;

__END__
