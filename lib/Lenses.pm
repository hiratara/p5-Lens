package Lenses;
use strict;
use warnings;
use Lens;
use Lens::Comonad::Costate;
use Exporter qw(import);

our @EXPORT_OK = qw(lens substr_lens);

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
}

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

1;
__END__
