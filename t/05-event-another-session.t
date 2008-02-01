
use Test::More tests => 23;

use strict;
use warnings;

SKIP: {
    unless ( -e 'cpan_network_tests' ) {
        skip 'Skipping network tests', 23;
    }

use POE qw(Component::CPAN::SQLite::Info);

POE::Component::CPAN::SQLite::Info->spawn( debug => 1, alias => 'info' );

POE::Session->create(
    package_states => [
        main => [ qw( _start ) ],
    ],
);

POE::Session->create(
    inline_states => {
        _start       => sub {
            $_[KERNEL]->alias_set('secondary');
        },
        freshened    => \&freshened,
        fetched_info => \&fetched_info,
    },
);

$poe_kernel->run;

sub _start {
    $poe_kernel->post( info => freshen => {
            event => 'freshened',
            ua_args => { timeout => 5, },
            session => 'secondary',
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
    
    SKIP: {
        if ( exists $input->{freshen_error} ) {
            if ( $input->{freshen_error} eq 'fetch' ) {
                ok(
                    exists $input->{freshen_errors},
                    "we got 'fetch' in {freshen_error}, {freshen_errors}"
                    . " must exist in this case"
                );
            }
            else {
                ok(
                    !exists $input->{freshen_errors},
                    "we got 'fetch' in {freshen_error}, {freshen_errors}"
                    . " should not exist in this case"
                );
            }
            $poe_kernel->post( info => 'shutdown' );
            skip 'Got "normal" error while fetching needed files', 21;
        }
        else {
            is(
                $input->{mirror},
                'http://cpan.perl.org',
                '{mirror} must default to http://cpan.perl.org',
            );
            ok(
                exists $input->{files},
                '{files} key must exist',
            );
            is(
                $input->{files}{packages},
                'cpan_sqlite_info/modules/02packages.details.txt.gz',
                '$input->{files}{packages} default',
            );
            is(
                $input->{files}{authors},
                'cpan_sqlite_info/authors/01mailrc.txt.gz',
                '$input->{files}{authors} default',
            );
            is(
                $input->{files}{modlist},
                'cpan_sqlite_info/modules/03modlist.data.gz',
                '$input->{files}{modlist} default',
            );
            
            foreach my $name ( qw(packages authors modlist) ) {
                isa_ok( $input->{requests}{ $name }, 'HTTP::Response' );
                isa_ok( $input->{uris    }{ $name }, 'URI'            );
            }
            
            is(
                $input->{freshen},
                1,
                '$input->{freshen} must exists with "1" as a value',
            );
            
            is(
                $input->{path},
                'cpan_sqlite_info/',
                '$input->{path} default',
            );
            
            is(
                $input->{_user},
                'test',
                'user defined args',
            );
            is(
                $input->{session},
                'secondary',
                '$input->{session}',
            );
            $poe_kernel->post( info => fetch_info => {
                    event   => 'fetched_info',
                    session => 'secondary',
                    _foo    => 'bar',
                }
            );
        }
    } # SKIP{}
}

sub fetched_info {
    my ( $kernel, $input ) = @_[ KERNEL, ARG0 ];
    
    is(
        ref $input,
        'HASH',
        'ARG0 in fetched_info event handler',
    );
    
    is(
        ref $input->{auths},
        'HASH',
        '$input->{auths}',
    );
    
    ok(
        exists $input->{auths}{ZOFFIX},
        'testing for {auths} containg authors. ZOFFIX must be there :)',
    );

    is(
        $input->{session},
        'secondary',
        '$input->{session}',
    );
    
    is(
        ref $input->{mods},
        'HASH',
        '$input->{mods}',
    );

    is(
        ref $input->{dists},
        'HASH',
        '$input->{dists}',
    );
    is(
        $input->{path},
        'cpan_sqlite_info/',
        '$input->{path} defaults',
    );
    $poe_kernel->post( info => 'shutdown' );
}

} # SKIP
