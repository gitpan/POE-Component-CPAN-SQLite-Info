use 5.008008;
use ExtUtils::MakeMaker;

unlink 'cpan_network_tests';

my $do_network = lc prompt(make_prompt_message(), 'y' );

if ( $do_network eq 'y' ) {
	open TOUCH, '>', 'cpan_network_tests';
	close TOUCH;
}


WriteMakefile(
    NAME              => 'POE::Component::CPAN::SQLite::Info',
    VERSION_FROM      => 'lib/POE/Component/CPAN/SQLite/Info.pm', 
    PREREQ_PM         => {
    	'LWP::UserAgent'		 => 2.036,
    	'File::Spec'			 => 3.2501,
    	Carp					 => 1.04,
		POE	                     => 0.9999,
		'POE::Wheel::Run'   	 => 1.2179,
		'POE::Filter::Reference' => 1.2187,
		'POE::Filter::Line'	     => 1.1920,
		'LWP::UserAgent'	     => 2.036,
		'CPAN::SQLite::Info'     => 0.18,
    }, 

    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/POE/Component/CPAN/SQLite/Info.pm', # retrieve abstract from module
       AUTHOR         => 'Zoffix Znet <zoffix@cpan.org>') : ()),
);


sub make_prompt_message {
	my $mess = <<'END_MESSAGE';

*********************************************************************
*********************************************************************

Some tests require you to have a functional network and for you to
be able to access http://cpan.perl.org.
Tests will not fail if network is not available, but will take much
longer to test.

Would you like to run network tests? [Y/n]:
END_MESSAGE

	chomp $mess;
	return $mess;
}