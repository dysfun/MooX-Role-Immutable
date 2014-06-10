package MooX::Zipper::Role::Replayable;

use Carp qw(carp croak);
use Moo::Role;
with 'MooX::Zipper::Role::Zipper';

has dir => (
    is => 'ro',
    lazy => 1,
    builder => sub { [] },
);

sub go {
    my ($self, @args) = @_;
	return $self->_go(@args);
}

sub _go {
    my ($self, $dir) = @_;
    my @dirs = (@{$self->dirs}, $dir);
    return $self->head->$dir->traverse(
        dir => [@dirs],
        zip => $self,
    );
}

sub dive {
    my ($self, @dirs) = @_;
    my $zip = $self;
    for my $dir (@dirs) {
        $zip = $zip->go($dir);
	}
    return $zip;
}

sub call {
    my ($self, $method, @args) = @_;
    return $self->but(
        head => $self->head->$method(@args),
    );
}

sub set {
    my ($self, %args) = @_;
    return $self->but(
        head => $self->head->but(%args)
    );
}

sub replace {
    my ($self, $new) = @_;
    return $self->but(
        head => $new,
    );
}

sub up {
    my $self = shift;
    my $count = shift || 1;
    my $zip = $self;
    for (1..$count) {
        $zip = $zip->zip->but(
            head => $zip->zip->head->but(
                $zip->dir => $zip->head
            ),
        );
    }
    return $zip;
}

sub top {
    my $self = shift;
    return $self unless $self->has_zip;
    return $self->up->top;
}

sub is_top {
    my $self = shift;
    return ! $self->has_zip;
}

sub focus {
    my $self = shift;
    $self->top->head;
}

sub do {
    my ($self, $code) = @_;
    for ($self->head->traverse) {
        # localises to $_
        return $self->but(
            head => $code->($_)->focus,
        );
    }
}

1
__END__
