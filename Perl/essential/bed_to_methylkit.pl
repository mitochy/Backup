#!/usr/bin/perl

use strict; use warnings;

my ($input, $output) = @ARGV;
die "usage: $0 <bismark_pileup_CpG.pl result> <output>\n" unless @ARGV == 2;

open (my $in, "<", $input) or die "Cannot read from $input: $!\n";
open (my $out, ">", $output) or die "Cannot write to $output: $!\n";
while (my $line = <$in>) {
	chomp($line);
	next if $line =~ /^track/;
	next if $line =~ /\#/;
	my ($chr, $start, $end, $name, $junnk, $strand) = split("\t", $line);
	my ($context, $covs, $meth) = split("_", $name);
	my $strand_meth = $strand eq "+" ? "F" : "R";
	my $freqC = $meth;	 # Not Converted = Methylated
	my $freqT = 100 - $meth; # Converted = Not Methylated
	print $out "$chr\.$start\t$chr\t$start\t$strand_meth\t$covs\t$freqC\t$freqT\n";
}
close $in;
close $out;
