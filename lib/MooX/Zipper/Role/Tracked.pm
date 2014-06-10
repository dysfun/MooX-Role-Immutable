package MooX::Zipper::Role::Tracked;

use Moo::Role;
with 'MooX::Zipper::Role::Zipper';
use MooX::Zippable::Autobox conditional=>1;

requires qw(_go);

has tracks => (
    is => 'ro',
    lazy => 1,
    builder => sub { [] },
);

sub go {
    my ($self, $direction) = @_;
    my $new = $self->but(tracks => [(@{$self->tracks}, $direction)]);
	$new->_go($direction);
}

1
__END__
