#!/usr/bin/perl

use strict; use warnings; use mitochy;

my ($folder, $min_kmer, $max_kmer) = @ARGV;
die "usage: get_kmer_kmer.pl <folder> <min_kmer (4)> <max_kmer (8)>\n" unless @ARGV;
$min_kmer = 4 if not defined($min_kmer);
$max_kmer = 8 if not defined($max_kmer);

for (my $i = $min_kmer; $i <= $max_kmer; $i++) {
	my $cmd = "perlscript_folder_run.pl get_kmer.pl_and_2_and_$i $folder logodd.txt";
	print "$cmd\n";
	system($cmd) == 0 or die "Failed to run: $!\n";
} 
