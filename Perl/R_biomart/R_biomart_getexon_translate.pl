#!/usr/bin/perl

use strict; use warnings;
use mitochy;
die "usage: R_biomart_getexon_translate.pl <fasta from R_biomart_getexon.pl>\n" unless @ARGV;

my ($input) = @ARGV;

my %fasta = mitochy::process_fasta($input);

my %def;
foreach my $def (sort keys %fasta) {
	my ($head, $num) = $def =~ /^>(KOG.+)_(\d+)_\d+_to_\d+_strand=/i;
	die "died at $def, $input\n" if not defined($head);
	#print "$head\t$num\n";
	$def{$head}[$num] = $def;
}

open (my $out, ">", "$input.prot") or die "Cannot write to $input.prot: $!\n";
foreach my $head (sort keys %def) {
	my $seq;
	my $strand;
	for (my $i = 0; $i < @{$def{$head}}; $i++) {
		next if not defined($def{$head}[$i]);
		#print "$head\t$def{$head}[$i]\n";
		$seq .= $fasta{$def{$head}[$i]}{'seq'};
	}

	#print "$seq\n";
	my $rev_seq = mitochy::revcomp($seq);

	my $trans = 0;	
	my $trans0 = mitochy::translate($seq, 0);
	my $count0 = $trans0 =~ tr/\*/\*/;
	#print "trans0 = $trans0\n";
	#print "plus 0: $count0\n";

	my $trans1 = mitochy::translate($seq, 1);
	my $count1 = $trans1 =~ tr/\*/\*/;
	#print "trans1 = $trans1\n";
	#print "plus 1: $count1\n";

	my $trans2 = mitochy::translate($seq, 2);
	my $count2 = $trans2 =~ tr/\*/\*/;
	#print "trans2 = $trans2\n";
	#print "plus 2: $count2\n";

	my $trans3 = mitochy::translate($rev_seq, 0);
	my $count3 = $trans3 =~ tr/\*/\*/;
	#print "trans3 = $trans3\n";
	#print "plus 3: $count3\n";

	my $trans4 = mitochy::translate($rev_seq, 1);
	my $count4 = $trans4 =~ tr/\*/\*/;
	#print "trans4 = $trans4\n";
	#print "plus 4: $count4\n";

	my $trans5 = mitochy::translate($rev_seq, 2);
	my $count5 = $trans5 =~ tr/\*/\*/;
	#print "trans5 = $trans5\n";
	#print "plus 5: $count5\n";

	my @trans = ($trans1, $trans2,  $trans3, $trans4, $trans5);

	for (my $i = 0; $i < @trans; $i++) {
		my $transx = $trans[$i];
		my $count = 0;
		my $prevcount = 0;
		my $countATG = 0;
		while ($transx =~ /\*/ig) {
			if ($seq =~ /^ATG/i) {
				$trans = mitochy::translate($seq, 0) if $` !~ /\w\w/i;
				$trans = mitochy::translate($`, 0) if $` =~ /\w\w/i;
				last;
			}
			else {
				$count = length($`);
				my $current = $count - $prevcount;
				$trans = substr($transx, $prevcount, $current) if length($trans) < $current;
				$prevcount = $count;
			}
		}
		last if $seq =~ /^ATG/i;

	}
	
	#while ($trans =~ /\*/ig) {
	#	print "$`\n";
	#}
	$trans =~ s/\*//ig;

	my $length_of_seq = int(length($seq)/3);
	my $length_of_prot = length($trans);
	print $out ">$head\n$trans\n";
	print $out "\#warning: length of seq is less than 50% of length_of_seq ($length_of_prot/$length_of_seq)\n" unless $length_of_prot*2/$length_of_seq >= 0.5;
	print $out "\#length of protein = $length_of_prot/$length_of_seq\n";
}
