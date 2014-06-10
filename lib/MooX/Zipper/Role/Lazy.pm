package MooX::Zipper::Role::Lazy;

use Carp qw(carp croak);
use Moo::Role;
with 'MooX::Zipper::Role::Tracked';

has handlers => (
  is => 'ro',
  lazy => 1,
  builder => sub {+{}}
);

sub add_handler {
    my ($self, $hook, $callback) = @_;
    croak("Can't overwrite handler for '$hook'")
        if defined $self->handlers->{$hook};
    return $self->but(
        handlers => { ( %{$self->handlers}, $hook => $callback ) },
    );
}

sub _go () {
    my ($self, $direction) = @_;
    my $new = $self->but(tracks => [(@{$self->tracks}, $direction)]);
}

sub go {
    my ($self, $direction) = @_;
    $self->_go(['go', $direction]);
}
sub call {
    my ($self, $method, @args) = @_;
    $self->_go(['call', $method, @args]);
}
sub set {
    my ($self, %args) = @_;
    return $self->_go(['set', %args]);
}
sub replace {
    my ($self, $new) = @_;
    return $self->_go(['replace', $new]);
}
sub up {
    my ($self, $count) = @_;
    croak("count must be numeric")
        unless integer($count);
    return $self->_go(['up', $count]);
}
sub top {
    my ($self) = @_;
    return $self->_go(['top']);
}
sub is_top {
    die("Can't is_top yet");
}

sub focus {
    my ($self, $subject) = @_;
    my $z = $self;
    foreach my $d ($self->tracks) {
        my ($callback, @args) = @{$self->handlers->{$d}};
        croak("No registered handler for '$d'")
            unless defined $callback;
        $z = $callback->(@args);
    }
    return $z;
}

sub do {
    my ($self, $subject, $code) = @_;
    for ($subject) {
        # localises to $_
        return $code->($_)->focus;
    }
}

1
__END__
