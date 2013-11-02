#!/usr/bin/perl

use strict; use warnings; use mitochy;

my ($input) = @ARGV;
die "usage: max_pars.pl <result from get_kmer.pl>\n" unless @ARGV == 1;

my %org;
open (my $in, "<", $input) or die "Cannot read from $input: $!\n";
open (my $out, ">", "$input.max.txt") or die "Cannot write to $input.max.txt: $!\n";

while (my $line = <$in>) {
	chomp($line);
	my @arr = split("\t", $line);
	foreach my $arr (@arr) {
		my ($org, $kmer, $score) = split("_", $arr);
		$org{$kmer}{$org} = $score;
	}
}

foreach my $kmer (sort keys %org) {
	foreach my $org (sort keys %{$org{$kmer}}) {
		print "$kmer.$org.$org{$kmer}{$org}\t";
	}
	print "\n";
}
