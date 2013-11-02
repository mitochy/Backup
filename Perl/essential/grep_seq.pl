#!/usr/bin/perl

use strict; use warnings;
use FAlite; use mitochy;

my ($input, $substr, $start_substr, $mode) = @ARGV;

die "usage: grep_seq.pl <fasta> <substr> <start_substr> <mode (1 from start, 2 from end)>\n" unless @ARGV >=3;
$mode = 1 if not defined($mode);
print "substr = $substr\nstart_substr = $start_substr\n";
open (my $in, "<", $input) or die "Cannor read from $input: $!\n";
open (my $out, ">", "$input.$substr.substr1.fa") or die "Cannot write to $input.$substr.substr1.xfa: $!\n" if $mode == 1;
open ($out, ">", "$input.$substr.substr2.fa") or die "Cannot write to $input.$substr.substr2fa: $!\n" if $mode == 2;

my $fasta = new FAlite($in);
while (my $entry = $fasta -> nextEntry) {
	my $hd = $entry -> def;
	my $sq = $entry -> seq;
	die "died at $hd\n" if not defined($sq);
	my $lengthseq = length($sq);
	my $start = $mode == 1 ? $start_substr : length($sq) - $start_substr - $substr;
	#if ($lengthseq >= $start_substr + $substr) {
	#my $remaining = $lengthseq - $start;
	#if ($remaining < $substr) {
	#	my $newseq = 
		$sq = substr($sq, $start, $substr);
		next if not defined($sq);
		print $out "$hd\n$sq\n";
	#}
	#else {
	#	#print $out "$hd\n$sq\n";
	#	print $out "$hd\nNA\n";
	#}
}

close $in;
close $out;
