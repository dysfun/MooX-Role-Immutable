package MooX::Zipper::Role::Zipper;

use Moo::Role;
with 'MooX::But';
use MooX::Zippable::Autobox conditional=>1;
requires qw(focus go up top is_top call set replace);

sub dive {
    my ($self, @dirs) = @_;
    my $zip = $self;
    for my $dir (@dirs) {
        $zip = $zip->go($dir);
    }
    return $zip;
}

1
__END__
