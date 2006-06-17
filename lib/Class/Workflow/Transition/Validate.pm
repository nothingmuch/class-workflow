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

	package MyTransition;
	use Moose;

	with qw/
		Class::Workflow::Transition
		Class::Workflow::Transition::Validate
	/;

	sub validate {
		my ( $self, $instance, %args ) = @_;

		die "only the owner can apply this transition"
			unless $args{user} eq $instance->owner;
	}

=head1 DESCRIPTION

This role will call the C<validate> method at the appropriate time.

C<validate> receives the same arguments as C<apply>, and is expected to die if
any of the parameters for the transition are invalid.

Technically, this role doesn't do much more than adding syntactic sugar for
C<before 'apply'>. However, it's value is in the convention that you can call
C<validate> without applying the body. This eases writing side effect free
introspection of transitions.

=cut


