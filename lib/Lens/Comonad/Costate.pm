package Lens::Comonad::Costate;
use Moo;
use namespace::clean;

has func  => (is => 'ro', isa => sub { ref $_[0] eq 'CODE' or die }, requires => 1);
has state => (is => 'ro', requires => 1);
extends 'Lens::Comonad';

sub _comp ($$) {
    my ($g, $f) = @_;
    sub { $g->($f->(@_)) };
}

sub counit { # (s -> a, s) -> a
    my $self = shift;
    $self->func->($self->state);
}

sub coflatten { # (s -> a, s) -> (s -> (s -> a, s), s)
    my $self = shift;
    my $class = ref $self;
    my $self_func = $self->func;
    $class->new(
        func => sub {
            my $state = shift;
            $class->new(
                func => $self_func,
                state => $state,
            );
        },
        state => $self->state,
    );
}

sub map {
    my ($self, $f) = @_;
    (ref $self)->new(
        func => _comp($f, $self->func),
        state => $self->state,
    );
}

sub coflat_map {
    my ($self, $f) = @_;
    $self->coflatten->map($f);
}

1;
__END__
