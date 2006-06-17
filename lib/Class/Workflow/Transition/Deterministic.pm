#!/usr/bin/perl

package Class::Workflow::Transition::Deterministic;
use Moose::Role;

use Carp qw/croak/;

has to_state => (
	does => "Class::Workflow::State",
	is   => "rw",
);

requires "apply_body";

sub apply {
	my ( $self, $instance, @args ) = @_;

	return $self->derive_instance(
		$instance,
		state => $self->to_state || croak "$self has no 'to_state'",
		$self->apply_body( $instance, @args ),
	);
}

__PACKAGE__;

__END__

=pod

=head1 NAME

Class::Workflow::Transition::Deterministic - A transition which knows which
state it leads to.

=head1 SYNOPSIS

	use Class::Workflow::Transition::Deterministic;

=head1 DESCRIPTION

=cut


