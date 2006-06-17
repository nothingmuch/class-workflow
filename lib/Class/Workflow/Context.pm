#!/usr/bin/perl

package Class::Workflow::Context;
use Moose;

has stash => (
	isa     => "HashRef",
	is      => "rw",
	default => sub { {} },
);

__PACKAGE__;

__END__

=pod

=head1 NAME

Class::Workflow::Context - The context in which a transition is being applied
(optional).

=head1 SYNOPSIS

	use Class::Workflow::Context;

=head1 DESCRIPTION

If you need to pass arbitrary arguments to the workflow, like the user who is
trying to apply a transition to the instance, or something like that then you
should probably use a Context object.

The Context object provides C<stash>, a writable hash which is essentially
free-for-all, but also allows you to add various utility methods and fields on
your own.

The only code that should manipulate a context within the application is within
the application of a transition.

=head1 DUCK TYPING

This class should not be considered mandatory or formal in any way - it's just
a convenient role that the first argument to standardized transition code
should do.

=cut


