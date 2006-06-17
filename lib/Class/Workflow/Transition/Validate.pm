#!/usr/bin/perl

package Class::Workflow::Transition::Validate;
use Moose::Role;

requires "validate";

before apply => sub {
	my ( $self, $instance, @args ) = @_;
	$self->validate( $instance, @args );
};

__PACKAGE__;

__END__

=pod

=head1 NAME

Class::Workflow::Transition::Validate - Provide a hook for validating a
transition (conditionals, input validators, etc).

=head1 SYNOPSIS

	use Class::Workflow::Transition::Validate;

=head1 DESCRIPTION

=cut


