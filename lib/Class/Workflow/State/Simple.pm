#!/usr/bin/perl

package Class::Workflow::State::Simple;
use Moose;

with qw/
	Class::Workflow::State
	Class::Workflow::State::TransitionSet
	Class::Workflow::State::AcceptHooks
/;

has name => (
	isa => "Str",
	is  => "rw",
);

sub accept_instance { };

around new => sub {
	my $next = shift;
	my ( $class, %params ) = @_;

	my $transitions = delete $params{transitions};

	my $self = $class->$next( %params );

	$self->transitions( @$transitions );

	$self;
};

__PACKAGE__;

__END__

=pod

=head1 NAME

Class::Workflow::State::Simple - 

=head1 SYNOPSIS

	use Class::Workflow::State::Simple;

=head1 DESCRIPTION

=cut


