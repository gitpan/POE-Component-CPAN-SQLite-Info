
use Test::More tests => 10;
BEGIN {
    use_ok('LWP::UserAgent');
    use_ok('File::Spec');
    use_ok('Carp');
    use_ok('POE');
    use_ok('POE::Wheel::Run');
    use_ok('POE::Filter::Reference');
    use_ok('POE::Filter::Line');
    use_ok('LWP::UserAgent');
    use_ok('CPAN::SQLite::Info');
    use_ok('POE::Component::CPAN::SQLite::Info');
};
