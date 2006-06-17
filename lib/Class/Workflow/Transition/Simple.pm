#!/usr/bin/perl

package Class::Workflow::Transition::Simple;
use Moose;

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

Class::Workflow::Transition::Simple - 

=head1 SYNOPSIS

	use Class::Workflow::Transition::Simple;

=head1 DESCRIPTION

=cut


