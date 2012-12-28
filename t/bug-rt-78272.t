use strict;
use warnings;
use Test::More tests => 1;
use Test::Fatal;

subtest 'Bug RT-78272: Arbitrary code execution from $ENV' => sub {

    # https://rt.cpan.org/Public/Bug/Display.html?id=78272
    my $e = $ENV{PACKAGE_STASH_IMPLEMENTATION} = "PP; exit 1";

    like(
        exception { require Package::Stash },
        qr/^Could not load Package::Stash::$e/,
        'Arbitrary code in $ENV throws exception'
    );

    like(
        exception {
            delete $INC{'Package/Stash.pm'};
            require Package::Stash;
        },
        qr/^Could not load Package::Stash::$e/,
        'Sanity check: forcing package reload throws the exception again'
    );

    is(
        exception {
            $ENV{PACKAGE_STASH_IMPLEMENTATION} = "PP";
            delete $INC{'Package/Stash.pm'};
            require Package::Stash;
            new_ok(
                'Package::Stash' => ['Foo'],
                'Loaded and able to create instances'
            );
        },
        undef,
        'Valid $ENV value loads correctly'
    );
};
