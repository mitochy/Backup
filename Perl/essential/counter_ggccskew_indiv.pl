#!/usr/bin/perl

use strict; use warnings; use FAlite; use mitochy; use Thread::Queue; use Getopt::Std;
use vars qw($opt_w $opt_s $opt_c $opt_m);
getopts("w:s:cm:");

my ($input) = @ARGV;
die "usage: [options] <fasta>
Options:
-w: Window size [default: 200]
-s: Step size [default: 1]
-c: This is a CEGMA input name (Chordates_Primates.hsapiens.fa)
-a: Get average instead of printing all
-m: Math function:
-m ave: average
-m max:  max of skew
-m med: average of 1/3 to 2/3 
" unless @ARGV == 1;

my $outName = mitochy::getFilename($input) if not ($opt_c);
($outName) = $input =~ /\w+\_\w+\.(\w+)\.fa/ if ($opt_c);
die "Undefined name (maybe not a CEGMA format?\n" if ($opt_c) and not defined($outName);
my $window = defined($opt_w) ? $opt_w : 200;
my $step   = defined($opt_s) ? $opt_s : 1;

open (my $in, "<", $input) or die;
open (my $outSkew, ">", "$outName\_skew.tsv") or die;
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
	my ($def, $seq) = @{$Q->dequeue};
	print "Doing $count\n" if $count % 100 == 0;
	$seq = uc($seq);
	my @skew;
	for (my $i = 0; $i < length($seq)-$window; $i+=$step) {
		my $subseq = substr($seq, $i, $window);
		my ($GG) = mitochy::count_nuc($subseq,"GG");
		my ($CC) = mitochy::count_nuc($subseq,"CC");
		my $skewtot = $CC == 0 ? 0 : ($GG - $CC) / ($GG + $CC);
		push(@skew, $skewtot);
	}
	my $skew = \@skew;
	$result{$count}{name} = $def;
	$result{$count}{skew} = $skew;
}

foreach my $count (keys %result) {
	my @skew1 = @{$result{$count}{skew}};
	my $name  = $result{$count}{name};
	print $outSkew "$name\t";
	if (defined($opt_m)) {
		my ($skew) = (0,0,0);
		if ($opt_m eq "ave") {
			for (my $i = 0; $i < @skew1; $i ++) {
				$skew = $skew1[$i] eq "NA" ? $skew : $skew + ($skew1[$i] / @skew1);
			}
		}
		elsif ($opt_m eq "med") {
			my $count = 0;
			for (my $i = int(@skew1/3); $i <= int(@skew1*2/3); $i ++) {
				$count ++;
				$skew = $skew1[$i] eq "NA" ? $skew : $skew + $skew1[$i];
			}
			$skew /= $count;
		}
		elsif ($opt_m eq "max") {
			for (my $i = 0; $i < @skew1; $i ++) {
				$skew = $skew1[$i] if $skew1[$i] ne "NA" and $skew < $skew1[$i];
			}
		}
		print $outSkew "$skew\n";
	}
	else {
		for (my $i = 0; $i < @skew1; $i ++) {
			print $outSkew "$skew1[$i]";
			print $outSkew "\t" if $i != @skew1 - 1;
		}
		print $outSkew "\n";
	}
}
