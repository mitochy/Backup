#!/usr/bin/perl

use strict; use warnings; use mitochy;

my ($input) = @ARGV;
die "usage: $0 <bed_to_methylkit.pl> <BED6 from bismark_pileup_CpG.pl>\n" unless @ARGV == 1;

my ($folder, $name) = mitochy::getFilename($input, "folder");

open (my $in, "<", $input) or die "Cannot read from $input: $!\n";
open (my $out, ">", "$folder\/$name.methylkit") or die "Cannot write to $folder\/$name.methylkit: $!\n";
while (my $line = <$in>) {
	chomp($line);
	next if $line =~ /^track/;
	next if $line !~ /chr/;
	next if $line =~ /\#/;
	my ($chr, $start, $end, $name, $meth, $strand) = split("\t", $line);
	my ($context, $covs) = $name =~ /^(\w+)\_coverage(\d+)$/;
	my $strand_meth = $strand eq "+" ? "F" : "R";
	my $freqC = $meth;	 # Not Converted = Methylated
	my $freqT = 100 - $meth; # Converted = Not Methylated
	print $out "$chr\.$start\t$chr\t$start\t$strand_meth\t$covs\t$freqC\t$freqT\n";
}
close $in;
close $out;
