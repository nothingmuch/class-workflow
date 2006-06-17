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

	package MyTransition;
	use Moose;

	with qw/
		Class::Workflow::Transition
		Class::Workflow::Deterministic
	/;

	sub apply_body { # instead of 'sub apply'
		# body
	}

	# this may be changed to the following form in the future:
	augment apply => sub {
		# body
	};

=head1 DESCRIPTION

This role provides a base role for transitions which know their target state.

It overrides C<apply> with a default implementation that will derive an
instance for you, setting C<state> automatically, appending the return value
from C<apply_body> to that list.

You should consume this role unless you need to determine the target state
dynamically (probably not a good idea).

=head1 FIELDS

=over 4

=item to_state

The target state of the transition. Should do L<Class::Workflow::State>.

=back

=head1 METHODS

=over 4

=item apply

=back

=cut


