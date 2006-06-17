#!/usr/bin/perl

package Class::Workflow::State;
use Moose::Role;

requires "transitions"; # enumerate the transitions

requires "has_transition";
requires "has_transitions";

sub accept_instance {}

__PACKAGE__;

__END__

=pod

=head1 NAME

Class::Workflow::State - An instance's position in the workflow.

=head1 SYNOPSIS

	use Class::Workflow::State;

=head1 DESCRIPTION

=cut


