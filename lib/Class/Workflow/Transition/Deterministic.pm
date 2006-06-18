#!/usr/bin/perl

package Class::Workflow::Transition::Deterministic;
use Moose::Role;

use Carp qw/croak/;

has to_state => (
	does => "Class::Workflow::State",
	is   => "rw",
	required => 0,
);

has rv_to_instance => (
	isa => "Bool",
	is  => "rw",
	default => 0,
);

# FIXME augment + inner
requires "apply_body";

sub separate_rv {
	my ( $self, $instance, @rv ) = @_;

	if ( $self->rv_to_instance ) {
		return \@rv, ();
	} else {
		return [], @rv;
	}
}

sub apply {
	my ( $self, $instance, @args ) = @_;

	my ( $set_instance_attrs, @rv ) = $self->separate_rv(
		$instance,
		$self->apply_body( $instance, @args ),
	);

	my $new_instance = $self->derive_and_accept_instance(
		$instance => {
			state       => ( $self->to_state || croak "$self has no 'to_state'" ),
			@$set_instance_attrs,
		},
		@args,
	);

	return wantarray ? ($new_instance, @rv) : $new_instance;
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

=item rv_to_instance

See C<separate_rv>.

=back

=head1 METHODS

=over 4

=item apply

In scalar context returns the derived instance, in list caller also returns the
return value from C<apply_body>, as munged by C<separate_rv>.

=item separate_rv $insatnce, @rv

This is called with the insatnce and the return value from C<apply_body>.

It separates the fields to override in the instance from the return value to
the caller.

Currently it's all or nothing, one way or the other - C<rv_to_instance> governs
whether or not the entire return value is treated as a list of key/value pairs
to override in the instance or whther the entire return value is returned to
the caller.

=back

=head1 REQUIRED METHODS

=over 4

=item apply_body

The "inner" body of the function.

In the future instead of defining C<apply_body> you will do:

	augment apply => sub {
		# body
	};

And this role's C<apply> will use C<inner()>.

=back

=cut


