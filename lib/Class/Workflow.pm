#!/usr/bin/perl

package Class::Workflow;
use Moose;

use Class::Workflow::State::Simple;
use Class::Workflow::Transition::Simple;
use Class::Workflow::Instance::Simple;

use Carp qw/croak/;

has initial_state => (
	isa => "Str | Object",
	is  => "rw",
);

has instance_class => (
	isa => "Str",
	is  => "rw",
	default => "Class::Workflow::Instance::Simple",
);

sub new_instance {
	my ( $self, %attrs ) = @_;

	if ( !$attrs{state} ) {
		if ( my $initial_state = $self->state( $self->initial_state ) ) {
			$attrs{state} = $initial_state;
		} else {
			croak "Explicit state not specified and no initial state is set in the workflow.";
		}
	}

	$self->instance_class->new( %attrs );
}

use tt fields => [qw/state transition/];
[% FOREACH field IN fields %]

has _[% field %]s => (
	isa => "HashRef",
	is  => "ro",
	default => sub { return {} },
);

sub [% field %] {
	my ( $self, @params ) = @_;

	if ( @params == 1 ) {
		if ( ref($params[0]) eq "HASH" ) {
			@params = %{ $params[0] };
		} elsif ( ref($params[0]) eq "ARRAY" ) {
			@params = @{ $params[0] };
		}
	}

	if ( !blessed($params[0]) and !blessed($params[1]) and @params % 2 == 0 ) {
		# $wf->state( name => "foo", transitions => [qw/bar gorch/] )
		return $self->create_or_set_[% field %]_params( @params );
	} elsif ( !ref($params[0]) and @params % 2 == 1 ) {
		# my $state = $wf->state("new", %attrs); # create new by name, or just get_foo
		return $self->create_or_set_[% field %]( name => @params )
	} elsif ( @params == 1 and blessed($params[0]) and $params[0]->can("name") ) {
		# $wf->state( $state ); # set by object (if $object->can("name") )
		return $self->add_[% field %]( $params[0]->name => $params[0] );
	} elsif ( @params == 2 and blessed($params[1]) and !ref($params[0]) ) {
		# $wf->state( foo => $state ); # set by name
		return $self->add_[% field %]( @params );
	} else {
		if ( @params == 1 and blessed($params[0]) ) {
			croak "The [% field %] $params[0] must support the 'name' method.";
		} else {
			croak "'[% field %]' was called with invalid parameters. Please consult the documentation.";
		}
	}
}

sub get_[% field %] {
	my ( $self, $name ) = @_;
	$self->_[% field %]s->{$name}
}

sub get_[% field %]s {
	my ( $self, @names ) = @_;
	@{ $self->_[% field %]s }{@names}
}

sub add_[% field %] {
	my ( $self, $name, $obj ) = @_;
	
	if ( exists $self->_[% field %]s->{$name} ) {
		die unless $obj == $self->_[% field %]s->{$name};
		return $obj;
	} else {
		return $self->_[% field %]s->{$name} = $obj;
	}
}

sub rename_[% field %] {
	my ( $self, $name, $new_name ) = @_;
	my $obj = $self->delete_[% field %]( $name );
	$obj->name( $new_name ) if $obj->can("name");
	$self->add_[% field %]( $new_name => $obj );
}

sub delete_[% field %] {
	my ( $self, $name ) = @_;
	delete $self->_[% field %]s->{$name};
}

sub create_[% field %] {
	my ( $self, $name, @attrs ) = @_;
	$self->add_[% field %]( $name => $self->construct_[% field %]( @attrs ) );
}

sub construct_[% field %] {
	my ( $self, @attrs ) = @_;
	$self->[% field %]_class->new( @attrs );
}

sub [% field %]_class {
	"Class::Workflow::[% field | ucfirst %]::Simple";
}

sub autovivify_[% field %]s {
	my ( $self, @things ) = @_;
	map { $self->[% field %]($_) } @things;
}

sub create_or_set_[% field %] {
	my ( $self, %attrs ) = @_;

	my $name = $attrs{name} || croak "Every [% field %] must have a name";

	$attrs{transitions} = [ $self->autovivify_transitions( @{ $attrs{transitions} } ) ] if exists $attrs{transitions};
	$attrs{to_state}    = $self->state( $attrs{to_state} ) if exists $attrs{to_state};

	if ( my $obj = $self->get_[% field %]( $name ) ) {
		delete $attrs{name};
		foreach my $attr ( keys %attrs ) {
			$obj->$attr( $attrs{$attr} );
		}

		return $obj;
	} else {
		return $self->create_[% field %]( $name, %attrs );
	}
}

[% END %]
no tt;

__PACKAGE__;

__END__

=pod

=head1 NAME

Class::Workflow - Light weight workflow system.

=head1 SYNOPSIS

	use Class::Workflow;

	# a workflow object assists you in creating state/transition objects
	# it lets you assign symbolic names to the various objects to ease construction

	# you can still create the state, transition and instance objects manually.

	my $wf = Class::Workflow->new;


	# create a state, and set the transitions it can perform
	# set it as the initial state

	$wf->state(
		name => "new",
		transitions => [qw/accept reject/],
	);
	$wf->initial_state("new");


	# create a few more states

	$wf->state(
		name => "open",
		transitions => [qw/claim_fixed reassign/],
	);

	$wf->state(
		name => "rejected",
	);


	# transitions move instances from state to state
	
	# create the transition named "reject"
	# the state "new" refers to this transition
	# the state "rejected" is the target state

	$wf->transition(
		name => "reject",
		to_state => "rejected",
	);


	# create a transition named "accept",
	# this transition takes a value from the context (which contains the current acting user)
	# the context is used to set the current owner for the bug

	$wf->transition(
		name => "accept",
		to_state => "opened",
		body => sub {
			my ( $transition, $instance, $context ) = @_;
			return (
				owner => $context->user, # assign to the use who accepted it
			);
		},
	);


	# hooks are triggerred whenever a state is entered. They cannot change the instance
	# this hook calls a hypothetical method on the submitter object

	$wf->state( "reject" )->add_hook(sub {
		my ( $state, $instance ) = @_;
		$instance->submitter->notify("Your item has been rejected");
	});


	# the rest of the workflow definition is omitted for brevity


	# finally, use this workflow in the action that handles bug creation

	sub new_bug {
		my ( $submitter, %params ) = @_;

		return $wf->new_instance(
			submitter => $submitter,
			%params,
		);
	}

=head1 DESCRIPTION

=cut


