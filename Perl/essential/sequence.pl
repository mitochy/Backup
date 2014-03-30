#!/usr/bin/perl

use strict; use warnings; use Getopt::Std; use mitochy;
use vars qw($opt_n $opt_l $opt_o $opt_v);
getopts("n:l:o:v");

my @ARGV = ($opt_n, $opt_l, $opt_o);
check_sanity(@ARGV);

my ($number, $length, $output) = ($opt_n, $opt_l, $opt_o);
my @nucleotide = qw(A T G C N);
open (my $out, ">", $output) or die "Cannot write to $output: $!\n";

for (my $i = 0; $i < $number; $i++) {
	print $out ">$i\n";
	for (my $i = 0; $i < $length; $i++) {
		my $random = rand(100);
		my $nucleotide = $nucleotide[int($random/24)];
		$nucleotide = "N" if $random > 96;
		print $out "$nucleotide";
	}
	print $out "\n";
}

close $out;

system("cat $output") if ($opt_v);

sub check_sanity {
	my @array = @_;
	foreach my $array (@array) {
		print_usage() and die "\n" if not defined($array);
	}
}

sub print_usage {
	print "\nusage: $0 -n <fasta to be generated> -l <length> -o <output>\n";
}
