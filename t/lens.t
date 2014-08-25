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

sub substr_lens ($$) {
    my ($offset, $length) = @_;
    Lens->new(
        coalgebra => sub {
            my $data = shift;
            Lens::Comonad::Costate->new(
                func => sub {
                    my $str = shift;
                    (substr my $cloned = $data, $offset, $length) = $str;
                    $cloned;
                },
                state => (substr $data, $offset, $length),
            );
        },
    );
}

my $talk = Talk->new(
    speaker => Speaker->new(name => 'Masahiro Homma'),
    name    => "I love monads",
);

is +$name_lens->get($talk), "I love monads";
is +$name_lens->set($talk, "I love comonads")->name, "I love comonads";

is +($speaker_lens . $name_lens)->set($talk, "hiratara")->speaker->name,
   "hiratara";

is +($speaker_lens . $name_lens)->($talk),
   "Masahiro Homma";
is +($speaker_lens . $name_lens)->($talk, "hiratara")->speaker->name,
   "hiratara";

is +($speaker_lens . $name_lens . substr_lens 8, 1)->($talk),
   " ";
is +($speaker_lens . $name_lens . substr_lens 8, 1)->($talk, " hiratara ")
                                                   ->speaker->name,
   "Masahiro hiratara Homma";

is $talk->speaker->name, 'Masahiro Homma';

done_testing;
