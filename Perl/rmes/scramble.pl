#!/usr/bin/perl

use strict; use warnings; use mitochy;

my ($input) = @ARGV;

die "usage: scramble.pl fasta(s)\n" unless @ARGV;
my %fasta = mitochy::process_fasta($input);

for (my $i = 0; $i < 10; $i++) {
	open (my $out, ">", "$input.$i.rmesinput") or die "Cannot write to $input.$i.rmesinput: $!\n";
	
	print $out ">try1\n";
	foreach my $hd (keys %fasta) {
		my $seq = $fasta{$hd}{'seq'};
		my $newseq = mitochy::scramble($seq);
		print $out "$newseq";
		print $out "Z";
	}
	close $out;
}
