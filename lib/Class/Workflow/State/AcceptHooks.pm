#!/usr/bin/perl

package Class::Workflow::State::AcceptHooks;
use Moose::Role;

has hooks => (
	isa => "ArrayRef",
	is  => "rw",
	auto_deref => 1,
	default    => sub { [] },
);

sub clear_hooks {
	my $self = shift;
	$self->hooks( [] );
}

sub add_hook {
	my ( $self, $hook ) = @_;
	$self->add_hooks( $hook );
}

sub add_hooks {
	my ( $self, @hooks ) = @_;
	push @{ $self->hooks }, @hooks;
}

after accept_instance => sub {
	my ( $self, $instance, @args ) = @_;
	$_->( $instance, @args ) for $self->hooks;
};

__PACKAGE__;

__END__

=pod

=head1 NAME

Class::Workflow::State::AcceptHooks - 

=head1 SYNOPSIS

	use Class::Workflow::State::AcceptHooks;

=head1 DESCRIPTION

=cut


