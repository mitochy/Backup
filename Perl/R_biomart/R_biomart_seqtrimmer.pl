#!/usr/bin/perl

use strict; use warnings; use mitochy;

my ($input) = @ARGV;
die "usage: R_biomart_seqtrimmer.pl <R_biomart_getsequence.pl result.fa>\n" unless @ARGV;

open (my $in, "<", $input) or die "Cannot read from $input: $!\n";

my $fasta = new FAlite($in);
my %gene;
my $count = 0;
while (my $entry = $fasta -> nextEntry) {
	my $seq = $entry -> seq;
	my $def = $entry -> def;
	
	if (exists($gene{$def})) {
		$count++;
		#print "$def exists\n";
		$gene{$def} = $seq if length($seq) >= length($gene{$def});
	}
	$gene{$def} = $seq if not exists($gene{$def});
}

open (my $out, ">", "$input.out") or die "Cannot write to $input.out: $!\n";
foreach my $def (keys %gene) {
	print $out "$def\n$gene{$def}\n";
}
print "number = $count\n";
close $out;
close $in;
