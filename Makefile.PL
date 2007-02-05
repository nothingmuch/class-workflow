use ExtUtils::MakeMaker;


WriteMakefile
(
	NAME         => 'Class::Workflow',
	VERSION_FROM => 'lib/Class/Workflow.pm',
	PREREQ_PM    => {
		'Moose'         => '0.17',
		'Set::Object'   => '0.15',
		'Test::More'    => 0,
		'Test::use::ok' => 0,
		'Data::Compare' => 0,
		eval { require YAML::Syck } ? do { 'YAML::Syck' => '0.82' } : (),
	},
	INSTALLDIRS  => 'site',
	EXE_FILES    => [],
	PL_FILES     => {},
	SIGN         => 1,
)
;
