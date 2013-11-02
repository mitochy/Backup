#!/usr/bin/perl

use strict; use warnings; use FAlite; use mitochy; use Thread::Queue;

my ($input) = @ARGV;
die "usage: <fasta>\n" unless @ARGV == 1;

open (my $in, "<", $input) or die;
open (my $out1, ">", "$input\.dens.tsv") or die;
open (my $out2, ">", "$input\.cont.tsv") or die;
open (my $out3, ">", "$input\.skew.tsv") or die;
my $fasta = new FAlite($in);
my $Q = new Thread::Queue;
my $def;
while (my $entry = $fasta->nextEntry) {
	my $def = $entry->def;
	my $seq = $entry->seq;
	my @all = ($def, $seq);
	$Q->enqueue(\@all);
}
$Q->end;

my $count = 0;
my %result;
while ($Q->pending) {
	$count = $Q->pending();
	#print "$count job left\n" if $count % 1000 == 0;
	my ($def, $seq) = @{$Q->dequeue};
	my ($cpg, $gc, $skew) = mitochy::dinuc_window_count($seq,"C","G",200,1);
	$result{$count}{cpg}  = $cpg;
	$result{$count}{gc}   = $gc;
	$result{$count}{skew} = $skew;
	$result{$count}{name} = $def;
}

my @cpg;
my @gc;
my @skew;
foreach my $count (keys %result) {
	my @cpg1  = @{$result{$count}{cpg}};
	my @gc1   = @{$result{$count}{gc}};
	my @skew1 = @{$result{$count}{skew}};
	my $name  = $result{$count}{name};
	print $out1 "$name\t";
	print $out2 "$name\t";
	print $out3 "$name\t";
	for (my $i = 0; $i < @cpg1; $i++) {
		print $out1 "$cpg1[$i]";
		print $out2 "$gc1[$i]";
		print $out3 "$skew1[$i]";
		print $out1 "," if $i != @cpg1 - 1;
		print $out2 "," if $i != @cpg1 - 1;
		print $out3 "," if $i != @cpg1 - 1;
	}
	print $out1 "\n";
	print $out2 "\n";
	print $out3 "\n";
}
