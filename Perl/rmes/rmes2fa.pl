#!/usr/bin/perl

use strict; use warnings; use mitochy;

my ($input) = @ARGV;
die "usage: rmes2fa.pl <.rmesinput>\n" unless @ARGV;
open (my $in, "<", $input)  or die "Cannot read from $input: $!\n";

my @seq;
while (my $line = <$in>) {
	next if $line =~ />/;
	@seq = split("Z", $line);
}
close $in;

open (my $out, ">", "$input.fa") or die "Cannot write to $input.fa: $!\n";

for (my $i = 0; $i < @seq; $i++) {
	print $out ">seq_$i\n";
	print $out "$seq[$i]\n";
}

close $out;

