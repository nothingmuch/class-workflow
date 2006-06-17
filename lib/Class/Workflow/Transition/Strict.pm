#!/usr/bin/perl

package Class::Workflow::Transition::Strict;
use Moose::Role;

before apply => sub {
	my ( $self, $instance, @args ) = @_;
	my $state = $instance->state;

	unless ( $state->has_transition( $self ) ) {
		die "$self is not in $instance\'s current state ($state)"
	}
};

__PACKAGE__;

__END__

=pod

=head1 NAME

Class::Workflow::Transition::Strict - 

=head1 SYNOPSIS

	use Class::Workflow::Transition::Strict;

=head1 DESCRIPTION

=cut


