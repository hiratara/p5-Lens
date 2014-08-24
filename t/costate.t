use strict;
use warnings;
use Test::More;
use Lens::Comonad::Costate;

my $costate = Lens::Comonad::Costate->new(
    func => sub { length $_[0] }, state => "ABCDE",
);

is $costate->counit, 5;
is $costate->map(sub { $_[0] * 2 })->counit, 10;
is $costate->coflat_map(sub { $_[0]->counit * 3 })->counit, 15;
is $costate->coflat_map(sub { $_[0]->counit })->counit, 5;

done_testing;
