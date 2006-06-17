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

=cut


