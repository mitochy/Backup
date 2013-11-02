#!/usr/bin/perl

use strict; use warnings; use mitochy; use FAlite;

my ($input) = @ARGV;
die "usage: $0 <input>\n" unless @ARGV;

my ($folder, $name) = mitochy::get_filename($input);

open (my $in, "<", $input) or die "Cannot read from $input: $!\n";

my $fasta = new FAlite($in);
my ($A, $T, $G, $C, $N) = (0,0,0,0,0);
while (my $entry = $fasta->nextEntry()) {
	my $def = $entry->def;
	my $seq = $entry->seq;
	$A += $seq =~ tr/Aa/Aa/;
	$T += $seq =~ tr/Tt/Tt/;
	$G += $seq =~ tr/Gg/Gg/;
	$C += $seq =~ tr/Cc/Cc/;
	$N += $seq =~ tr/Nn/Nn/;
	
}

close $in;

my $total = $A + $G + $C + $T;

printf "
A: %.2f
T: %.2f
G: %.2f
C: %.2f
N: $N
", $A*100/$total, $T*100/$total, $G*100/$total, $C*100/$total;


