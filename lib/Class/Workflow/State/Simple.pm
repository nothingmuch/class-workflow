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

__PACKAGE__;

__END__

=pod

=head1 NAME

Class::Workflow::State::Simple - 

=head1 SYNOPSIS

	use Class::Workflow::State::Simple;

=head1 DESCRIPTION

=cut


