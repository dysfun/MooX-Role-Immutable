package MooX::Zipper::Role::Untracked;

use Moo::Role;
with 'MooX::Zipper::Role::Zipper';

requires qw(_go);

has dir => (
    is => 'ro',
    required => 1,
);

sub go {
    my ($self, $direction) = @_;
    my $new = $self->but(dir => [(@{$self->tracks}, $direction)]);
	return $new->_go($direction);
}

1
__END__
