package MooX::Zipper::Role::Eager;

use Carp qw(carp croak);
use Scalar::Util qw(blessed);
use Moo::Role;
with 'MooX::Zipper::Role::Zipper';
use MooX::Zippable::Autobox conditional=>1;

use Data::Dumper 'Dumper';

has head => (
    is => 'ro',
);

has zip => (
    is => 'ro',
    predicate => 'has_zip',
);

sub _go {
    my ($self, $dir) = @_;
	croak("self->head cannot '$dir'")
	    unless $self->head->can($dir);
    croak("self->head->$dir is falsey")
        unless $self->head->$dir;
    warn Dumper($self);
    warn Dumper([@_]);
    croak("not blessed: " . Dumper $self->head->$dir)
	    unless blessed($self->head->$dir);
    return $self->head->$dir->traverse(
        dir => $dir,
        zip => $self,
    );
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
