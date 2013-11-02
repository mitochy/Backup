#!/usr/bin/perl -w
use strict;

my %C = (
	'AAA' => 'K', 'AAC' => 'N', 'AAG' => 'K', 'AAT' => 'N', 
	'ACA' => 'T', 'ACC' => 'T', 'ACG' => 'T', 'ACT' => 'T', 
	'AGA' => 'R', 'AGC' => 'S', 'AGG' => 'R', 'AGT' => 'S', 
	'ATA' => 'I', 'ATC' => 'I', 'ATG' => 'M', 'ATT' => 'I', 
	'CAA' => 'Q', 'CAC' => 'H', 'CAG' => 'Q', 'CAT' => 'H', 
	'CCA' => 'P', 'CCC' => 'P', 'CCG' => 'P', 'CCT' => 'P', 
	'CGA' => 'R', 'CGC' => 'R', 'CGG' => 'R', 'CGT' => 'R', 
	'CTA' => 'L', 'CTC' => 'L', 'CTG' => 'L', 'CTT' => 'L', 
	'GAA' => 'E', 'GAC' => 'D', 'GAG' => 'E', 'GAT' => 'D', 
	'GCA' => 'A', 'GCC' => 'A', 'GCG' => 'A', 'GCT' => 'A', 
	'GGA' => 'G', 'GGC' => 'G', 'GGG' => 'G', 'GGT' => 'G', 
	'GTA' => 'V', 'GTC' => 'V', 'GTG' => 'V', 'GTT' => 'V', 
	'TAA' => '*', 'TAC' => 'Y', 'TAG' => '*', 'TAT' => 'Y', 
	'TCA' => 'S', 'TCC' => 'S', 'TCG' => 'S', 'TCT' => 'S', 
	'TGA' => '*', 'TGC' => 'C', 'TGG' => 'W', 'TGT' => 'C', 
	'TTA' => 'L', 'TTC' => 'F', 'TTG' => 'L', 'TTT' => 'F'
);

my %R = (
	A => ['A'],
	C => ['C'],
	G => ['G'],
	T => ['T'],
	K => ['G', 'T'],
	M => ['A', 'C'],
	R => ['G', 'A'],
	Y => ['T', 'C'],
	W => ['A', 'T'],
	S => ['G', 'C'],
	B => ['C', 'T', 'G'],
	D => ['A', 'G', 'T'],
	H => ['A', 'C', 'T'],
	V => ['A', 'C', 'G'],
	N => ['A', 'C', 'G', 'T'],
);

my @alphabet = split(//,"ACGTRYKMWSBDHVN");
print "my \%Codon = (\n";
my $i = 0;
foreach my $x (@alphabet) {
	foreach my $y (@alphabet) {
		foreach my $z (@alphabet) {
			my @codons = codify($x, $y, $z);
			my @aa;
			foreach my $codon (@codons) {push @aa, $C{$codon}}
			my $first = $aa[0];
			my $same = 1;
			foreach my $test (@aa) {
				if ($test ne $first) {$same = 0; last}
			}
			if ($same) {
				print "\t'$x$y$z' => '$first',";
				$i++;
				print "\n" if $i % 4 == 0;
			}
		}
	}
}
print ");\n";

sub codify {
	my ($x, $y, $z) = @_;
	my @codons;
	foreach my $n1 (@{$R{$x}}) {
		foreach my $n2 (@{$R{$y}}) {
			foreach my $n3 (@{$R{$z}}) {
				push @codons, "$n1$n2$n3";
			}
		}
	}
	return @codons;
}
