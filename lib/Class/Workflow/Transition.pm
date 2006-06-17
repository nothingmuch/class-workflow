#!/usr/bin/perl

package Class::Workflow::Transition;
use Moose::Role;

use Carp qw/croak/;

sub derive_instance {
	my ( $self, $proto_instance, %attrs ) = @_;

	croak "You must specify the next state of the instance"
		unless exists $attrs{state};

	my $state = $attrs{state};

	my $instance = $proto_instance->derive(
		transition => $self,
		%attrs,
	);

	$state->accept_instance( $instance );

	return $instance;
}

__PACKAGE__;

__END__

=pod

=head1 NAME

Class::Workflow::Transition - A function over an instance.

=head1 SYNOPSIS

	use Class::Workflow::Transition;

=head1 DESCRIPTION

=cut


