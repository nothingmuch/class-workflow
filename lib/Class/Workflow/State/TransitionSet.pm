#!/usr/bin/perl

package Class::Workflow::State::TransitionSet;
use Moose::Role;
use Moose::Util::TypeConstraints;

use Set::Object;

subtype 'Set::Object'
	=> as Object
	=> where { $_[0]->isa("Set::Object") };

coerce "Set::Object"
	=> from ArrayRef
	=> via { Set::Object->new(@{ $_[0] }) };

has transitions => (
	isa      => "Set::Object",
	coerce   => 1,
	accessor => "transition_set",
	default  => sub { Set::Object->new },
);

sub transitions {
	my ( $self, @transitions ) = @_;

	if ( @transitions ) {
		$self->transition_set( Set::Object->new( @transitions ) );
		return @transitions;
	} else {
		return $self->transition_set->members;
	}
}

sub add_transitions {
	my ( $self, @transitions ) = @_;
	$self->transition_set->insert( @transitions );
}

sub has_transition {
	my ( $self, $transition ) = @_;
	$self->transition_set->includes( $transition );
}

sub has_transitions {
	my ( $self, @transitions ) = @_;
	$self->transition_set->includes( @transitions );
}

__PACKAGE__;

__END__

=pod

=head1 NAME

Class::Workflow::State::TransitionSet - A state that implements transition meta
data using Set::Object.

=head1 SYNOPSIS

	package MyState;
	with "Class::Workflow::State::TransitionSet";

=head1 DESCRIPTION

This is a concrete role that implements C<transitions>, C<has_transition> and
C<has_transitions> as required by L<Class::Workflow::State>, and adds
C<add_transitions> as well.

Transition storage is implemented internally with L<Set::Object>.

Note that you may construct like this:

	Class->new(
		transitions => \@transitions,
	);

and the transition set will be coerced from that array reference.

=head1 METHODS

See L<Class::Workflow::State>

=over 4

=item has_transition

=item has_transitions

=item transitions

=item add_transitions

=item transition_set

=back

=cut


