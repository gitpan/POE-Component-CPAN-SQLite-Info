
use Test::More tests => 5;

use strict;
use warnings;

use POE qw(Component::CPAN::SQLite::Info);

POE::Component::CPAN::SQLite::Info->spawn( debug => 1, alias => 'info',
mirror => 'fake.fake.fake' );

POE::Session->create(
    package_states => [
        main => [ qw( _start freshened ) ],
    ],
);

$poe_kernel->run;

sub _start {
    $poe_kernel->post( info => freshen => {
            event => 'freshened',
            ua_args => { timeout => 1, },
            _user => 'test',
        }
    );
}

sub freshened {
    my ( $kernel, $input ) = @_[ KERNEL, ARG0 ];
    is(
        ref $input,
        'HASH',
        "output from freshen() must be a hashref",
    );
    if ( $input->{freshen_error} eq 'fetch' ) {
        ok(
            exists $input->{freshen_errors},
            "we got 'fetch' in {freshen_error}, {freshen_errors}"
            . " must exist in this case"
        );
        foreach my $name ( qw(packages authors modlist) ) {
            ok(
                exists $input->{freshen_errors}{ $name },
                "\$input->{freshen_errors}{ $name } must exists()",
            );
        }
    }
    else {
        ok(
            !exists $input->{freshen_errors},
            "we got 'fetch' in {freshen_error}, {freshen_errors}"
            . " should not exist in this case"
        );
        skip 'error is in dir creation, skipping {freshen_errors}', 3;
    }
    $poe_kernel->post( info => 'shutdown' );
}