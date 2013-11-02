#!/usr/bin/perl

use strict; use warnings;
my ($sam) = @ARGV;
die "usage: $0 <sam>\n" unless @ARGV;

open (my $in, "<", $sam) or die;
open (my $out, ">", "$sam.fastq") or die;
while (my $line = <$in>) {
	chomp($line);
	next if $line =~ /^@/;
	my @arr = split("\t", $line);
	my ($name, $seq, $qual) = ($arr[0], $arr[9], $arr[10]);
	print $out "\@$name\n$seq\n+\n$qual\n";
}
close $out;
close $in;
