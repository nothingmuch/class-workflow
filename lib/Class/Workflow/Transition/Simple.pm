#!/usr/bin/perl

package Class::Workflow::Transition::Simple;
use Moose;

# FIXME with Class::Workflow::Transition should not be necessary
with qw/
	Class::Workflow::Transition
	Class::Workflow::Transition::Deterministic
	Class::Workflow::Transition::Strict
	Class::Workflow::Transition::Validate
/;

has name => (
	isa => "Str",
	is  => "rw",
);

has body => (
	isa => "CodeRef",
	is  => "rw",
	default => sub { sub { return () } },
);

has validator => (
	isa => "CodeRef",
	is  => "rw",
	default => sub { sub { 1 } },
);

has ignore_rv => (
	isa => "Bool",
	is  => "rw",
	default => 1,
);

sub apply_body {
	my ( $self, $instance, @args ) = @_;
	my @ret = $self->body->( $instance, @args );
	return ( $self->ignore_rv ? () : @ret );
}

sub validate {
	my ( $self, $instance, @args ) = @_;
	$self->validator->( $instance, @args ) || die "Transition input validation error";
}

__PACKAGE__;

__END__

=pod

=head1 NAME

Class::Workflow::Transition::Simple - A useful class (or base class) for
writing transitions.

=head1 SYNOPSIS

	use Class::Workflow::Transition::Simple;

	my $t = Class::Workflow::Transition::Simple->new(
		name      => "feed",
		to_state  => $not_hungry, # Class::Workflow::Transition::State
		ignore_rv => 0,
		body      => sub {
			my ( $self, $instance, @args ) = @_;

			my $remain = $global_food_warehouse->reduce_quantity;

			return (
				remaining_food => $remain,
			);
		},
	);

=head1 DESCRIPTION

=head1 FIELDS

=over 4

=item name

This is just a string. It can be used to identify the transition in a parent
object like C<Class::Workflow> if any.

=item to_state

This is the state the transition will transfer to. This comes from
C<Class::Workflow::Transition::Deterministic>.

=item ignore_rv

Whether or not to ignore the return value from the transition body. Defaults to
true.

=item body

This is an optional sub (it defaults to C<<sub { }>>) which will be called
during apply, after any validation.

It can return a list of key/value pairs, that will be passed to
C<derive_instance> as long as C<ignore_rv> is set to false

=item validator

This is an optional sub ref (it defaults to C<<sub { 1 }>>) which will be called
to validate input before applying C<body>.

=back

=cut


