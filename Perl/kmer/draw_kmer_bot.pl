#!/usr/bin/perl

use strict; use warnings;

my $COMMAND = "cpglite.pl -w 250 -y 10 -o 0 -g 0";

my ($input) = @ARGV;
die "usage: $0 <sort.n.txt file (kmer_score file)>\n" unless @ARGV;
my %kmer;
open (my $in, "<", $input) or die "Cannot read from $input: $!\n";
while (my $line = <$in>) {
	chomp($line);
	my @arr = split("\t", $line);
	foreach my $arr (@arr) {
		my ($org, $kmer, $score) = $arr =~ /^(\w+)\.fa\_(\w+)\_-{0,1}(\d+\.*\d*)/i;
		die "die at $arr since not defined org\n" if not defined($org) or not defined($score);
		$kmer{$org}{'kmer'}{$kmer} = $score;
	}
}

close $in;

my $cpglite_folder = "/home/mitochi/Desktop/Work/newcegma/cpglite/";
my @fasta = <$cpglite_folder/*.fa>;

my @fails;
my @org;
foreach my $fasta (@fasta) {
	print "$fasta\n";
	my ($org) = $fasta =~ /(\w+)_geneseq/i;
	my $finalcmd;
	die "died at $fasta since not defined org\n" unless defined($org);
	my $count;
	foreach my $kmer (sort {$kmer{$org}{'kmer'}{$b} <=> $kmer{$org}{'kmer'}{$a}} keys %{$kmer{$org}{'kmer'}}) {
		my $score = $kmer{$org}{'kmer'}{$kmer};
		$count++;
		my $length = length($kmer);
		print "$length\n";
		last if $count >= length($kmer)*4;
		my $COMMAND2 = " -m $kmer -c $cpglite_folder/$org\_geneseq_chrCEGMA_all.fa &";
		#print "$COMMAND\n";
		my $cmd = $COMMAND . $COMMAND2;
		system($cmd) == 0 or push(@fails, $cmd);
	}
	sleep(15);
}

#foreach my $fail (@fails) {
#	print "$fail\n";
#}

open (my $out, ">", "$input.failed") or print "Cannot write to $input.failed: $!\n";
foreach my $fail (@fails) {
	print $out "$fail\n";
	#print "$cmd\n";
	#system($cmd);
	#sleep(60);
}
