#!/usr/bin/perl

package Class::Workflow::State::Simple;
use Moose;

# FIXME with Class::Workflow::State should be implied
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

Class::Workflow::State::Simple - A useful class (or base class) for writing
states.

=head1 SYNOPSIS

	use Class::Workflow::State::Simple;

	my $state = Class::Workflow::State::Simple->new(
		name => "foo",
		transitions => [ $tn ], # objects
	);

=head1 DESCRIPTION

=head1 FIELDS

=over 4

=item name

=back

=head1 ROLES

This class consumes the following roles:

=over 4

=item *

L<Class::Workflow::State::TransitionSet>

=item *

L<Class::Workflow::State::AcceptHooks>

=back

=cut


