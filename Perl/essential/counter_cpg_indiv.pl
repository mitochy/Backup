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
open (my $outDens, ">", "$outName\_dens.tsv") or die;
open (my $outCont, ">", "$outName\_cont.tsv") or die;
open (my $outSkew, ">", "$outName\_skew.tsv") or die;
my $fasta = new FAlite($in);
my $Q = new Thread::Queue;
my $def;
my $record_number = 0;
while (my $entry = $fasta->nextEntry) {
	my $def = $entry->def;
	my $seq = $entry->seq;
	my @all = ($def, $seq, $record_number);
	$Q->enqueue(\@all);
	$record_number++;
}
$Q->end;

my $count = 0;
my %result;
while ($Q->pending) {
	$count = $Q->pending();
	my ($def, $seq, $record_number) = @{$Q->dequeue};
	$seq = uc($seq);
	my ($dens, $cont, $skew) = mitochy::dinuc_window_count_NA($seq,"C","G",$window,$step);
	$result{$record_number}{name} = $def;
	$result{$record_number}{dens}  = $dens;
	$result{$record_number}{cont}   = $cont;
	$result{$record_number}{skew} = $skew;
}

foreach my $count (sort {$a <=> $b} keys %result) {
	my @dens1  = @{$result{$count}{dens}};
	my @cont1   = @{$result{$count}{cont}};
	my @skew1 = @{$result{$count}{skew}};
	my $name  = $result{$count}{name};
	print $outDens "$name\t";
	print $outCont "$name\t";
	print $outSkew "$name\t";
	if (defined($opt_m)) {
		my ($dens, $cont, $skew) = (0,0,0);
		if ($opt_m eq "ave") {
			for (my $i = 0; $i < @dens1; $i ++) {
				$dens = $dens1[$i] eq "NA" ? $dens : $dens + ($dens1[$i] / @dens1);
				$cont = $cont1[$i] eq "NA" ? $cont : $cont + ($cont1[$i] / @cont1);
				$skew = $skew1[$i] eq "NA" ? $skew : $skew + ($skew1[$i] / @skew1);
			}
		}
		elsif ($opt_m eq "med") {
			my $count = 0;
			for (my $i = int(@dens1/3); $i <= int(@dens1*2/3); $i ++) {
				$count ++;
				$dens = $dens1[$i] eq "NA" ? $dens : $dens + $dens1[$i];
				$cont = $cont1[$i] eq "NA" ? $cont : $cont + $cont1[$i];
				$skew = $skew1[$i] eq "NA" ? $skew : $skew + $skew1[$i];
			}
			$dens /= $count;
			$cont /= $count;
			$skew /= $count;
		}
		elsif ($opt_m eq "max") {
			for (my $i = 0; $i < @dens1; $i ++) {
				$dens = $dens1[$i] if $dens1[$i] ne "NA" and $dens < $dens1[$i];
				$cont = $cont1[$i] if $cont1[$i] ne "NA" and $cont < $cont1[$i];
				$skew = $skew1[$i] if $skew1[$i] ne "NA" and $skew < $skew1[$i];
			}
		}

		print $outDens "$dens\n";
		print $outCont "$cont\n";
		print $outSkew "$skew\n";
	}
	else {
		for (my $i = 0; $i < @dens1; $i ++) {
			print $outDens "$dens1[$i]";
			print $outCont "$cont1[$i]";
			print $outSkew "$skew1[$i]";
			print $outDens "\t" if $i != @dens1 - 1;
			print $outCont "\t" if $i != @dens1 - 1;
			print $outSkew "\t" if $i != @dens1 - 1;
		}
		print $outDens "\n";
		print $outCont "\n";
		print $outSkew "\n";
	}
}
