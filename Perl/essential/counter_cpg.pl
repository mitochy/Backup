#!/usr/bin/perl

use strict; use warnings; use FAlite; use mitochy; use Thread::Queue;

my ($input) = @ARGV;
die "usage: <fasta>\n" unless @ARGV == 1;

my $window = 200;
my $step   = 1;
open (my $in, "<", $input) or die;
open (my $out1, ">", "$input\.dens.tsv") or die;
open (my $out2, ">", "$input\.cont.tsv") or die;
open (my $out3, ">", "$input\.skew.tsv") or die;
my $fasta = new FAlite($in);
my $Q = new Thread::Queue;
my $def;
while (my $entry = $fasta->nextEntry) {
	my $seq = $entry->seq;
	$Q->enqueue($seq);
}
$Q->end;

my $count = 0;
my %result;
while ($Q->pending) {
	$count = $Q->pending();
	print "$count job left\n" if $count % 1000 == 0;
	my $seq = $Q->dequeue;
	my ($cpg, $gc, $skew) = mitochy::dinuc_window_count($seq,"C","G",$window, $step);
	$result{$count}{cpg}  = $cpg;
	$result{$count}{gc}   = $gc;
	$result{$count}{skew} = $skew;
}

my @cpg;
my @gc;
my @skew;
foreach my $count (keys %result) {
	my @cpg1  = @{$result{$count}{cpg}};
	my @gc1   = @{$result{$count}{gc}};
	my @skew1 = @{$result{$count}{skew}};
	for (my $i = 0; $i < @cpg1; $i++) {
		#print "$i\t$skew1[$i]\n";
		$cpg[$i]  += $cpg1[$i];
		$gc[$i]   += $gc1[$i];
		$skew[$i] += $skew1[$i];
	}
}

my $total = keys %result;
for (my $i = 0; $i < @cpg; $i++) {
	my $pos = $i * $step + $window / 2;
	my $cpg  = $cpg[$i]  / $total;
	my $gc   = $gc[$i]   / $total;
	my $skew = $skew[$i] / $total;
	print $out1 "$pos\t$cpg\n";
	print $out2 "$pos\t$gc\n";
	print $out3 "$pos\t$skew\n";
}

