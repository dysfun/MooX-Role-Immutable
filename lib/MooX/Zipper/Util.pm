package MooX::Zipper::Util;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(atom integer);

sub atom { shift =~ /^[a-z](?:[a-z0-9:_]*)$/ }
sub integer { $_ = shift; looks_like_num($_) && /^[0-9]+$/; }

1
__END__
