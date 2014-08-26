use strict;
use warnings;

package Talk;
use Moo;
use namespace::clean;
has speaker => (is => 'ro', requires => 1);
has name    => (is => 'ro', requires => 1);

package Speaker;
use Moo;
use namespace::clean;
has name    => (is => 'ro', requires => 1);

package main;
use Test::More;
use Lenses qw(lens substr_lens);

my $talk = Talk->new(
    speaker => Speaker->new(name => 'Masahiro Homma'),
    name    => "I love monads",
);

is lens('name')->get($talk), "I love monads";
is lens('name')->set($talk, "I love comonads")->name, "I love comonads";

is +(lens('speaker') . lens('name'))->set($talk, "hiratara")->speaker->name,
   "hiratara";

is +(lens('speaker') . lens('name'))->($talk),
   "Masahiro Homma";
is +(lens('speaker') . lens('name'))->($talk, "hiratara")->speaker->name,
   "hiratara";

is +(lens('speaker') . lens('name') . substr_lens 8, 1)->($talk),
   " ";
is +(lens('speaker') . lens('name') . substr_lens 8, 1)->($talk, " hiratara ")
                                                   ->speaker->name,
   "Masahiro hiratara Homma";

is $talk->speaker->name, 'Masahiro Homma';

done_testing;
