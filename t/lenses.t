use strict;
use warnings;
use Lenses qw(hash_lens);
use Test::More;

my %hash = (abcde => {hijkl => "fghi"});
is +(hash_lens("abcde") . hash_lens("hijkl"))->(\%hash), "fghi";
my $new_hash = (hash_lens("abcde") . hash_lens("hijkl"))->(\%hash, "FGHI");
is $hash{abcde}{hijkl}, "fghi";
is $new_hash->{abcde}{hijkl}, "FGHI";

done_testing;
