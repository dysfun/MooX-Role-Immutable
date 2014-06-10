package MooX::But::Immutable;
use Safe::Isa;
use Moo::Role;
with 'MooX::But';
sub but {
    my ($self, %new) = @_;
    %new = (%$self, %new);
    return $self->new(map {
        $_ => ($new{$_}->$_can('but') ? $new{$_}->but : $new{$_})
    } keys %new);
}

1
__END__
