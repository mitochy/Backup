#!/usr/bin/perl

use strict; use warnings; use mitochy;

my ($input) = @ARGV;

die "usage: fa2rmes.pl fasta(s)\n" unless @ARGV;
my %fasta = %{mitochy::process_fasta($input)};

open (my $out, ">", "$input.rmesinput") or die "Cannot write to $input.rmesinput: $!\n";
	
print $out ">$input\n";
foreach my $hd (keys %fasta) {
	my $seq = $fasta{$hd}{'seq'};
	print $out "$seq";
	print $out "Z";
}
close $out;
