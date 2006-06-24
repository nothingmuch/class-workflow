#!/usr/bin/perl

package Class::Workflow::Transition::Simple;
use Moose;

use overload '""' => "stringify", fallback => 1;

# FIXME with Class::Workflow::Transition should not be necessary
with qw/
	Class::Workflow::Transition
	Class::Workflow::Transition::Deterministic
	Class::Workflow::Transition::Strict
	Class::Workflow::Transition::Validate::Simple
/;

has name => (
	isa => "Str",
	is  => "rw",
);

sub stringify {
	my $self = shift;
	if ( defined( my $name = $self->name ) ) {
		return $name;
	}
	return overload::StrVal($_[0]);
}

has body => (
	isa => "CodeRef",
	is  => "rw",
	default => sub { sub { return () } },
);

has set_fields => (
	isa => "HashRef",
	is  => "rw",
	default => sub { {} },
);

# if set_fields is set it overrides body_sets_fields
has body_sets_fields => (
	isa => "Bool",
	is  => "rw",
	default => 0,
);

sub apply_body {
	my ( $self, $instance, @args ) = @_;
	my $body = $self->body;

	# if we have a predefined set of fields
	unless ( $self->body_sets_fields ) {
		return (
			$self->set_fields,
			$self->$body( $instance, @args ),
		);
	} else {
		# otherwise let the body control everything
		return $self->$body( $instance, @args );
	}
}

__PACKAGE__;

__END__

=pod

=head1 NAME

Class::Workflow::Transition::Simple - A useful class (or base class) for
writing transitions.

=head1 SYNOPSIS

	use Class::Workflow::Transition::Simple;

	my $t = Class::Workflow::Transition::Simple->new(
		name           => "feed",
		to_state       => $not_hungry, # Class::Workflow::Transition::State
		body_sets_fields => 1,
		body           => sub {
			my ( $self, $instance, @args ) = @_;

			my $remain = $global_food_warehouse->reduce_quantity;

			return (
				remaining_food => $remain,
			);
		},
	);

=head1 DESCRIPTION

=head1 FIELDS

=over 4

=item name

This is just a string. It can be used to identify the transition in a parent
object like C<Class::Workflow> if any.

=item to_state

This is the state the transition will transfer to. This comes from
C<Class::Workflow::Transition::Deterministic>.

=item ignore_rv

Whether or not to ignore the return value from the transition body. Defaults to
true.

=item body

This is an optional sub (it defaults to C<<sub { }>>) which will be called
during apply, after any validation.

It can return a list of key/value pairs, that will be passed to
C<derive_and_accept_instance> as long as C<ignore_rv> is set to false

The body is invoked as a method on the transition.

=item validate

=item validators

=item clear_validators

=item add_validators

These methods come from L<Class::Workflow::Transition::Validate::Simple>.

=back

=head1 ROLES

This class consumes the following roles:

=over 4

=item *

L<Class::Workflow::Transition::Deterministic>

=item *

L<Class::Workflow::Transition::Strict>

=item *

L<Class::Workflow::Transition::Validate::Simple>

=back

=cut


