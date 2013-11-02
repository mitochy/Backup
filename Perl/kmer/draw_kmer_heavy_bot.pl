#!/usr/bin/perl

use strict; use warnings;

my $COMMAND = "cpgheavy.pl";

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

my $cpglite_folder = "/home/mitochi/Desktop/Work/newcegma/cpgheavy/bot";
my @fasta = <$cpglite_folder/*.fa>;

my @fails;
my @org;
my $cmd;
foreach my $fasta (@fasta) {
	print "$fasta\n";
	my ($org) = $fasta =~ /(\w+)_geneseq/i;
	my $finalcmd;
	die "died at $fasta since not defined org\n" unless defined($org);
	my $count;
	my $COMMAND2;
	print "Nexted at $org since kmer is 0\n" and next if (keys %{$kmer{$org}{'kmer'}} == 0);
	foreach my $kmer (sort {$kmer{$org}{'kmer'}{$a} <=> $kmer{$org}{'kmer'}{$b}} keys %{$kmer{$org}{'kmer'}}) {
		print "$kmer\n" if $org =~ /tadhaerens/;
		my $score = $kmer{$org}{'kmer'}{$kmer};
		$count++;
		my $length = length($kmer);
		#print "$length\n";
		last if $count >= 20;
		$COMMAND2 .= "pc,$kmer\.add.";
		#print "$COMMAND\n";
	}
	$COMMAND2 =~ s/.and.$//ig;
	$cmd .= $COMMAND . " -g " . $COMMAND2 . " -c $fasta & ";
	#system($cmd) == 0 or push(@fails, $cmd);
	

}
print "$cmd\n";
#system($cmd);
#foreach my $fail (@fails) {
#	print "$fail\n";
#}

#open (my $out, ">", "$input.failed") or print "Cannot write to $input.failed: $!\n";
#foreach my $fail (@fails) {
#	print $out "$fail\n";
	#print "$cmd\n";
	#system($cmd);
	#sleep(60);
#}
