#!/usr/bin/perl

use strict; use warnings; use mitochy; use FAlite;

my ($input) = @ARGV;
die "usage: $0 <input>\n" unless @ARGV;

my ($name) = mitochy::getFilename($input);

open (my $in, "<", $input) or die "Cannot read from $input: $!\n";

my $fasta = new FAlite($in);
my ($A, $T, $G, $C, $N) = (0,0,0,0,0);
my $CpG = 0;
while (my $entry = $fasta->nextEntry()) {
	my $def = $entry->def;
	my $seq = $entry->seq;
	$A += $seq =~ tr/Aa/Aa/;
	$T += $seq =~ tr/Tt/Tt/;
	$G += $seq =~ tr/Gg/Gg/;
	$C += $seq =~ tr/Cc/Cc/;
	$N += $seq =~ tr/Nn/Nn/;
	while ($seq =~ /CG/ig) {
		$CpG++;
	}
}

close $in;

my $total = $A + $G + $C + $T;

printf "
A: %.2f ($A)
T: %.2f ($T)
G: %.2f ($G)
C: %.2f ($C)
N: $N
Total: $total
CpG: $CpG
", $A*100/$total, $T*100/$total, $G*100/$total, $C*100/$total;


