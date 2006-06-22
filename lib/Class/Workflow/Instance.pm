#!/usr/bin/perl

package Class::Workflow::Instance;
use Moose::Role;

has prev => ( # the instance this instance was derived from
	does     => "Class::Workflow::Instance",
	is       => "ro",
	required => 0,
);

has transition => ( # the transition this instance is a result of
	does     => "Class::Workflow::Transition",
	is       => "ro",
	required => 0,
);

has state => ( # the state the instance is currently in
	does     => "Class::Workflow::State",
	is       => "ro",
	required => 1,
);

sub derive {
	my ( $self, @fields ) = @_;
	return $self->meta->clone_object( $self, @fields, prev => $self );
}

__PACKAGE__;

__END__

=pod

=head1 NAME

Class::Workflow::Instance - An instance in a workflow, with state and history.

=head1 SYNOPSIS

	use Class::Workflow::Instance;

=head1 DESCRIPTION

=cut


