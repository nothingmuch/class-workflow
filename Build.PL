#!/usr/bin/perl -w

use strict;

use Module::Build;

Module::Build->new(
	module_name => 'Class::Workflow',
	license => 'perl',
	requires => {
		'Moose'         => '0.09_03',
		'Test::More'    => 0,
		'Test::use::ok' => 0,
		'Set::Object'   => '0.15',
	},
	reccomends => {
		YAML => 0,
	},
	create_makefile_pl => 'traditional',
	sign => 1,
)->create_build_script;

