=head1 NAME

MooX::Zipper::Lazy - lazy immutable cursor onto a data structure

=head1 SYNOPSIS

See L<MooX::Zippable>

=cut

package MooX::Zipper::Lazy;
use Carp qw(carp croak);
use Safe::Isa;
use Moo;
with 'MooX::But';
use MooX::Zippable::Autobox conditional=>1;

has dirs => (
    is => 'ro',
    lazy => 1,
    builder => sub { [] },
);

has zipper => (
    is => 'ro',
    lazy => 1,
    builder => sub { undef }
);

sub dive { shift->go(@_); }

sub go {
    my ($self, @dirs) = @_;
    croak("Directions must all be strings")
      if grep ref($_), @dirs;
    return $self->_go(['go', [@dirs]]);
}

sub _go {
    my ($self, @dirs) = @_;
    return $self->but(
        dirs => (@{$self->dirs}, @dirs)
    );
}

sub call {
    my ($self, $method, @args) = @_;
    return $self->_go(['call', [$method, @args]]);
}

sub set {
    my ($self, %args) = @_;
    return $self->_go(['set', {%args}]);
}

sub replace {
    my ($self, $new) = @_;
    return $self->_go(['replace', $new]);
}

sub up {
    my $self = shift;
    my $count = shift || 1;
    croak("Count must be numeric")
        unless $count =~ /^[0-9]+$/;
    return $self->_go(['up', $count]);
}

sub top {
    my $self = shift;
    return $self->_go(['top']);
}

sub zip {
    my ($self, $zipper) = @_;
    return $self->_go(['zip', $zipper]);
}

sub is_top {
    my ($self, $zipper) = @_;
    return $self->_play($zipper, 1)->is_top;
}

sub combine {
    my (@zippers) = @_;
    croak("Can only combine with Lazy")
        if grep !$_->$_isa('MooX::Zipper::Lazy');
    while (@zippers > 2) {
        my $new = (shift @zippers)->zip(shift @zippers);
        unshift @zippers, $new;
    }
    return shift @zippers;
}


sub _play {
    my ($self, $zipper, $quietly) = @_;
    croak("You need to pass a zipper to focus or is_top if you didn't provide a 'zip' attributed to the Lazy constructor")
        unless ($zipper || $self->zipper);
    my @working = @{$self->dirs};
    while (my $d = shift @working) {
        croak("Please don't tamper with my innards")
            unless ref($d) eq 'ARRAY';
        if ($d->[0] eq 'go') {
            foreach my $d (@{$d->[1]}) {
                $zipper->go($d);
            }
         } elsif ($d->[0] eq 'up') {
             $zipper->up($d->[1]);
         } elsif ($d->[0] eq 'top') {
             $zipper->top;
         } elsif ($d->[0} eq 'zip') {
             unshift @working, @{ $d->[1]->dirs };
         } elsif (!$quietly) {
             if ($d->[0] eq 'call') {
                 $zipper->call(@{$d->[1]});
             } elsif ($d->[0] eq 'set') {
                 $zipper->set(%{$d->[1]})
             } elsif ($d->[0] eq 'replace') {
                 $zipper->replace($d->[1];
             }
         }
    }
    return $zipper;
}

sub focus {
    my ($self, $zipper) = @_;
    $self->_play($zipper);
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

=head1 METHODS

All zippers have the following methods

=head2 C<$zipper-E<gt>go($accessor)>

Traverses to an accessor of the object, keeping a breadcrumb trail back to the previous
object, so that it knows how to zip all the data back up.

=head2 C<$zipper-E<gt>set($accessor =E<gt> $value)>

Seemingly "update" a field of the object.  In fact, behind the scenes, the zipper is
calling C<but> and returning a copy of the object with the values updated.

=head2 C<$zipper-E<gt>call($method =E<gt> @args)>

Assumes that C<$method> returns a copy of the same object.  As with C<set>, you can
imagine that C<call> is updating the object in place, but in fact behind the scenes
everything is immutable.  (In fact, C<set> is itself implemented as:
C<$zipper-E<gt>call( but => $accessor => $value )>)

=head2 C<$zipper-E<gt>up>

Go back up a level

=head2 C<$zipper-E<gt>top>

Go back to the top of the object.  The returned value is I<still> a zipper!  To
return the object instead, use C<focus>

=head2 C<$zipper-E<gt>focus>

Return to the top of the zipper, zipping up all the data you've changed using
C<call> and C<set>, and return the modified copy of the object.

=head2 Other zipper methods

It is possible to create zippers for specific classes.  Examples are supplied for
perl's native Hash, Array, and Scalar types, using autobox.  See the classes for
L<MooX::Zipper::Native>, L<MooX::Zipper::Hash>, L<MooX::Zipper::Array>,
L<MooX::Zipper::Scalar> for details.

=cut

1;
