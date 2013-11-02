#!/usr/bin/perl

use strict; use warnings;

my $COMMAND = "cpgheavy.pl";
my @nomode;
my ($input, $mode) = @ARGV;
die "usage: $0 <sort.n.txt file (kmer_score file)>\n" unless @ARGV;
my %kmer;
open (my $in, "<", $input) or die "Cannot read from $input: $!\n";
while (my $line = <$in>) {
	chomp($line);
	my @arr = split("\t", $line);
	foreach my $arr (@arr) {
		my ($org, $kmer, $score) = $arr =~ /^(\w+)\.fa\_(\w+)\_-{0,1}(\d+\.*\d*)/i;
		next if $org !~ /hsapiens/;
		die "die at $arr since not defined org\n" if not defined($org) or not defined($score);
		$kmer{$org}{'kmer'}{$kmer} = $score;
	}
}

close $in;

my $cpglite_folder = "/home/mitochi/Desktop/Work/newcegma/cpgheavy/";

my @fasta = qw(protists fungiA fungiB plantsA plantsB tunicates worms insects fishes amphibians birds mammals);

my @fails;
my @org;
my $cmd;
foreach my $fasta (@fasta) {
	print "$fasta\n";
	my $finalcmd;
	my $count;
	my $COMMAND2;
	my $org = "hsapiens";
	my @nomode;
	print "Nexted at $org since kmer is 0\n" and next if (keys %{$kmer{$org}{'kmer'}} == 0);
	foreach my $kmer (sort {$kmer{$org}{'kmer'}{$a} <=> $kmer{$org}{'kmer'}{$b}} keys %{$kmer{$org}{'kmer'}}) {
		my $score = $kmer{$org}{'kmer'}{$kmer};
		$count++;
		print "pc,$kmer.add." if not defined($mode);
		my $length = length($kmer);
		#print "$length\n";
		last if $count >= 20;
		$COMMAND2 = "cpgheavy.pl -g pc,$kmer\.add.oe,$kmer -m -a $fasta & ";
		#print "$COMMAND\n";
		#print "$COMMAND2\n";
		$cmd .= $COMMAND2;

	}
	

}
print "\n";
#foreach my $fail (@fails) {
#	print "$fail\n";
#}
#print "$cmd\n";
#foreach my $nomode (@nomode) {
#	print "$nomode\n" if not defined($mode);
#}
print "use $0 <input> run\n to run bash script\n" if not defined($mode);
system($cmd) if defined($mode);
#open (my $out, ">", "$input.failed") or print "Cannot write to $input.failed: $!\n";
#foreach my $fail (@fails) {
#	print $out "$fail\n";
	#print "$cmd\n";
	#system($cmd);
	#sleep(60);
#}
