package Lens;
use Lens::Comonad::Costate;
use Moo;
use namespace::clean;
use overload (
    '.' => 'chain', '&{}' => 'accessor',
    fallback => 1
);

our $VERSION = '0.01';

has coalgebra => ( # coalgebra of costate comonad
    is => 'ro', isa => sub {ref $_[0] eq 'CODE' or die}, requires => 1,
);

sub get {
    my ($self, $data) = @_;
    $self->coalgebra->($data)->state;
}

sub set {
    my ($self, $data, $value) = @_;
    $self->coalgebra->($data)->func->($value);
}

sub chain {
    my ($self, $other) = @_;
    Lens->new(
        coalgebra => sub {
            my $data = shift;
            Lens::Comonad::Costate->new(
                func  => sub {
                    my $state = shift;
                    $self->set(
                        $data,
                        $other->set($self->get($data), $state)
                    );
                },
                state => $other->get($self->get($data)),
            );
        },
    );
}

sub accessor {
    my $self = shift;
    sub { @_ > 1 ? $self->set(@_) : $self->get(@_) };
}

1;
__END__

=encoding utf-8

=head1 NAME

Lens - Blah blah blah

=head1 SYNOPSIS

  use Lens;

=head1 DESCRIPTION

Lens is

=head1 AUTHOR

Masahiro Honma E<lt>hiratara@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2014- Masahiro Honma

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
