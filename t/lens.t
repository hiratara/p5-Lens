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
use Lens::Comonad::Costate;
use Lens;

my $speaker_lens = Lens->new(
    coalgebra => sub {
        my $talk = shift;
        Lens::Comonad::Costate->new(
            func => sub {
                my $speaker = shift;
                (ref $talk)->new(
                    %$talk,
                    speaker => $speaker,
                )
            },
            state => $talk->speaker,
        );
    },
);

my $name_lens = Lens->new(
    coalgebra => sub {
        my $data = shift;
        Lens::Comonad::Costate->new(
            func => sub {
                my $name = shift;
                (ref $data)->new(
                    %$data,
                    name => $name,
                )
            },
            state => $data->name,
        );
    },
);

my $talk = Talk->new(
    speaker => Speaker->new(name => 'Masahiro Homma'),
    name    => "I love monads",
);

is +$name_lens->get($talk), "I love monads";
is +$name_lens->set($talk, "I love comonads")->name, "I love comonads";

is +($speaker_lens . $name_lens)->set($talk, "hiratara")->speaker->name,
   "hiratara";

done_testing;
