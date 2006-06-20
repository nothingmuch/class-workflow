#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';

use ok "Class::Workflow";
use ok "Class::Workflow::Context";

{
	package POP3::Connection;
	use Moose;

	# stateless protocol code
	# the view in MVC

	has socket => (
		isa => "Object",
		is  => "ro",
		handles => [qw/is_open write readline/],
	);

	sub ok {
		my ( $self, $response ) = @_;
		$self->respond("+OK" => $response);
	}

	sub err {
		my ( $self, $response ) = @_;
		$self->respond("-ERR" => $response);
	}

	sub respond { # MMD-esque
		my ( $self, $prefix, $response ) = @_;

		if ( ref($response) ) {
			$self->send_multiline( $prefix, $response );
		} else {
			$self->send_simple( $prefix, $response );
		}
	}

	sub send_simple {
		my ( $self, $prefix, $response ) = @_;
	}

	sub receive {
		my ( $self, $c ) = @_;
		# blocking parse and return a command
	}

	package POP3::Server;
	use Moose;

	# stateless backend code
	# the model in MVC

	has mail_store => (
		# ...
	);

	sub verify_user_password {
		my ( $self, $user, $password ) = @_;
		return 1;
	}

	sub uidl {
		my ( $self, %params ) = @_;
	}

	sub list {
		my ( $self, %params ) = @_;
	}

	sub top {
		my ( $self, %params ) = @_;
	}

	sub retr {
		my ( $self, %params ) = @_;
	}

	package POP3::Session;
	use Moose;

	# stateful
	# the controller in MVC
	# the session doubles as a context

	our $Workflow;

	has server => (
		isa => "POP3::Server",
	);

	has workflow_instance => (
		isa => "POP3::Workflow::Instance",
		is  => "rw",
		default => sub { $Workflow->new_instance() },
	);

	has connection => (
		isa => "POP3::Connection",
		is  => "ro",
	);

	# not really necessary
	sub loop {
		my ( $self, $command, @args ) = @_;

		while ( $self->connection->is_open ) {
			my ( $command, @args ) = $self->connection->receive;
			$self->command( $command, @args );
		}
	}

	sub command {
		my ( $self, $command, @args ) = @_;

		my $i = $self->workflow_instance;

		my $connection = $self->connection;

		if ( my $transition = $i->state->get_transition($command) ) {
			eval {
				my ( $new_instance, $response ) = $transition->apply( $i, $self, @args );

				$self->workflow_instance( $new_instance );

				my $status = $new_instance->error ? "err" : "ok";
				$connection->$status( $response );
			};

			$connection->err( "Internal error" ) if $@;
		} else {
			$connection->err( "Invalid command" );
		}
	}

	package POP3::Workflow::Instance;
	use Moose;

	extends "Class::Workflow::Instance::Simple";

	has server => (
		# ...
	);

	has user => (
		isa => "Str",
		is  => "ro",
	);
}

my $w = $POP3::Session::Workflow = Class::Workflow->new;

# the stupid state names are from RFC 1939

$w->initial_state("authorization");

# define all the states

$w->state(
	name => "authorization",
	transitions => [qw/user apop/],
);

$w->state(
	name => "authorization_accepting_password",
	transitions => [qw/pass/],
);

$w->state(
	name => "transaction",
	transitions => [qw/list stat retr dele noop rset quit top uidl/],
);

$w->state(
	name => "update",
	auto_transition => "close_connection",
);

$w->state("disconnected");


# transitions for the authorization state

$w->transition(
	name     => "user",
	to_state => "accepting_password",
	body     => sub {
		my ( $self, $instance, $c, $username ) = @_;
		return ( user => $username ),
	},
);

$w->transition(
	name        => "pass",
	to_state    => "transaction",
	error_state => "invalid_password",
	validators => [
		sub {
			my ( $self, $instance, $c, $password ) = @_;
			die "Incorrect login"
				unless $c->server->validate_password( $instance->user, $password );
		}
	],
);

$w->state(
	name => "invalid_password",
	auto_transition => "reset_user",
);

$w->transition(
	name       => "reset_user",
	to_state   => "authorization",
	set_fields => {
		user  => undef,
	},
);



# transitions in the transaction state

foreach my $command (qw/list retr top uidl/) {
	$w->transition(
		name     => $command,
		to_state => "transaction",
		body => sub {
			my ( $self, $instance, $c, $message ) = @_;
			return $c->server->$command(
				message => $message,
				user    => $instance->user,
			);
		},
	);
}

$w->transition(
	name     => "noop",
	to_state => "transaction",
);

$w->transition(
	name     => "quit",
	to_state => "update",
);


# close the connection in the update state

$w->transition(
	name     => "close_connection",
	to_state => "disconnected",
	body     => sub {
		my ( $self, $instance, $c ) = @_;
		$c->connection->close;
	},
);


