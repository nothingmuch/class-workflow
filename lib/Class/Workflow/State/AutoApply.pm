#!/usr/bin/perl

package Class::Workflow::State::AutoApply;
use Moose::Role;

use Carp qw/croak/;

sub BUILD {
	my $self = shift;
	if ( my $auto = $self->auto_transition ) {
		unless ( $self->has_transition($auto) ){
			unless ( $self->can("add_transitions") ) {
				croak "$self must support the add_transitions method if "
				. "you don't put the auto_transition in the transitions list"
			}

			$self->add_transitions($auto);
		}
	}
}

has auto_transition => (
	does => "Class::Workflow::Transition",
	is   => "rw",
	required => 0,
);

around accept_instance => sub {
	my $next = shift;
	my ( $self, $orig_instance, @args ) = @_;
	my $instance = $self->$next( $orig_instance, @args );

	return $self->apply_auto_transition( $instance, @args ) || $instance;
};

sub apply_auto_transition {
	my ( $self, $instance, @args ) = @_;

	if ( my $auto_transition = $self->auto_transition ) {
		return $auto_transition->apply( $instance, @args );
	}

	return;
}

__PACKAGE__;

__END__

=pod

=head1 NAME

Class::Workflow::State::AutoApply - Automatically apply a transition upon
arriving into a state.

=head1 SYNOPSIS

	package MyState;
	use Moose;

	with qw/Class::Workflow::State::AutoApply/;
	
	my $state = Mystate->new( auto_transition => $t );

	my $i2 = $state->accept_instance( $i, @args ); # automatically calls $t->apply( $i, @args )

=head1 DESCRIPTION

This state role is used to automatically apply a transition

=head1 PARTIAL TRANSITIONS

If an auto-application may fail validation or something of the sort you can do
something like:

	around apply_auto_transition => sub {
		my $next = shift;
		my ( $self, $instance, @args ) = @_;

		eval { $self->$next( $instance, @args ) }

		die $@ unless $@->isa("SoftError");
	}

If apply_auto_transition returns a false value then the original instance will
be returned automatically, at which point the intermediate state is the current
state.

=cut


