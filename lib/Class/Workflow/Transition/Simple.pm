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

has validators => (
	isa => "ArrayRef",
	is  => "rw",
	auto_deref => 1,
	default    => sub { [] },
);

has ignore_rv => (
	isa => "Bool",
	is  => "rw",
	default => 1,
);

has ignore_validator_rv => (
	isa => "Bool",
	is  => "rw",
	default => 0,
);

sub apply_body {
	my ( $self, $instance, @args ) = @_;
	my $body = $self->body;
	my @ret = $self->$body( $instance, @args );
	return ( $self->ignore_rv ? () : @ret );
}

sub add_validators {
	my ( $self, @validators ) = @_;
	push @{ $self->validators }, @validators;
}

sub clear_validators {
	my $self = shift;
	$self->validators([]);
}

sub validate {
	my ( $self, $instance, @args ) = @_;

	my $ignore_rv = $self->ignore_validator_rv;

	my @errors;
	foreach my $validator ( $self->validators ) {
		my $ok = eval { $self->$validator->( $instance, @args ) };

		if ( $@ ) {
			push @errors, $@;
		} elsif ( !$ignore_rv and !$ok ) {
			push @errors, "general error";
		}
	}

	die "Transition input validation error: @errors" if @errors;
	# FIXME add @errors to an exception object that stringifies

	return 1;
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
C<derive_and_accept_instance> as long as C<ignore_rv> is set to false

The body is invoked as a method on the transition.

=item ignore_validator_rv

This is useful if your validators only throw exceptions.

Defaults to false

=item validators

This is an optional list of sub refs which will be called to validate input
before applying C<body>.

They should raise an exception or return a false value if the input is bad.

They may put validation result information inside the
L<Class::Workflow::Context> or equivalent, if one is used.

A more comprehensive solution is to override the C<validate> method yourself
and provide rich exception objects with validation error descriptors inside
them.

The validators are invoked as methods on the transition.

IF C<ignore_validator_rv> is true then only exceptions are considered input
validations.

=item add_validators @code_refs

=item clear_validators

Modify the list of validators.

=back

=head1 ROLES

This class consumes the following roles:

=over 4

=item *

L<Class::Workflow::Transition::Deterministic>

=item *

L<Class::Workflow::Transition::Strict>

=item *

L<Class::Workflow::Transition::Validate>

=back

=cut


