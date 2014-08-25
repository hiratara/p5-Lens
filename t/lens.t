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

sub lens ($) {
    my $field = shift;
    Lens->new(
        coalgebra => sub {
            my $data = shift;
            Lens::Comonad::Costate->new(
                func => sub {
                    my $value = shift;
                    (ref $data)->new(
                        %$data,
                        $field => $value,
                    )
                },
                state => $data->$field,
            );
        }
    );
};

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
