#!/usr/bin/perl

use strict; use warnings; use mitochy;
use Cache::FileCache;
my ($Nmer, $mode) = @ARGV;
die "usage: $0 <N mer [2-8]> \n" unless @ARGV;
my $input = "/home/mitochi/Desktop/Work/newcegma/kmer/min500plus500/sort/sort.$Nmer.txt";
my $cache = new Cache::FileCache();
$cache -> set_cache_root("/home/mitochi/Desktop/Cache");

my %kmer;
my $kmerdb = $cache -> get("kmerdb_$Nmer");
if (not defined($kmerdb)) {
	print "Not defined cache for kmer $Nmer, creating...\n";
	$kmerdb = PROCESS_KMER($input);
	print "Done!\n";
}
%kmer = %{$kmerdb};
my %org = %{mitochy::Global_Var("orglist")};
my $COMMAND = "cpgheavy.pl";
my $MAX_KMER = 9999;
#my $MAX_KMER_COUNT = $Nmer*2;
my $MAX_KMER_SCORE = -3;
my @nomode;
my $cpglite_folder = "/home/mitochi/Desktop/Work/newcegma/cpgheavy/";
#my @fasta = qw(protists fungiA fungiB plantsA plantsB tunicates worms insects fishes amphibians birds mammals);
my @fasta = qw(birds cnidarians fishesA fishesB fishesC fishesD fungiA fungiB insectsA insectsB mammals plantsA plantsB plantsC porifera protistsA protistsB protistsC reptiles tunicates worms);
my @fails;
my @org;
my @cmd;
foreach my $fasta (@fasta) {
	my @kmerlist = @{PROCESS_KMER_FAMILY($fasta)};
	#for (my $i = 0; $i < @kmerlist; $i++) {
	#	print "$fasta\t$kmerlist[$i][0]\t$kmerlist[$i][1]\t$kmerlist[$i][2]\n";
	#}
	#die;	
	print "Processing $fasta\n";
	my $finalcmd;
	my $count;
	my $COMMAND2;
	my @nomode;
	#print "Nexted at $org since kmer is 0\n" and next if (keys %{$kmer{$org}{'kmer'}} == 0);
	#foreach my $kmer (sort {$kmer{$org}{'kmer'}{$a} <=> $kmer{$org}{'kmer'}{$b}} keys %{$kmer{$org}{'kmer'}}) {
	foreach my $org (@{$org{$fasta}}) {
		#print "$fasta $org\n";
		my $cmd = "cpgheavy.pl -g ";
		
		#print "Nexted because not exists $fasta $org\n" and next unless (-e "/home/mitochi/Desktop/Work/newcegma/cpgheavy/$fasta.$org\_geneseq_chrCEGMA_all.fa");
		for (my $i = 0; $i < @kmerlist; $i++) {
			my ($kmer, $score) = ($kmerlist[$i][0], $kmerlist[$i][1]);
			my $length = length($kmer);
			$score = int(100* $score)/100;
			$cmd .= "pc,$kmer,$score.add.";
		}
		$cmd =~ s/.add.$/ /;
		$cmd .= "-m -a $fasta &";
		next if @kmerlist == 0;
		$cmd =~ s/\&\& $//;
		push(@cmd, $cmd);
#		$cmd .= " -k -m -a $fasta.$org\_geneseq_chrCEGMA_all.fa & ";
	last;
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
if (@cmd == 0) {
	print "no kmer exists\n";
}
foreach my $cmd (@cmd) {
	print "$cmd\n\n";
	system($cmd) if defined($mode);
}
print "use $0 <input> run\n to run bash script\n" if not defined($mode);

#system($cmd) if defined($mode);
#open (my $out, ">", "$input.failed") or print "Cannot write to $input.failed: $!\n";
#foreach my $fail (@fails) {
#	print $out "$fail\n";
	#print "$cmd\n";
	#system($cmd);
	#sleep(60);
#}


sub PROCESS_KMER {
	my ($input) = @_;
	my %kmer;
	my $linecount = 0;
	open (my $in, "<", $input) or die "Cannot read from $input: $!\n";
	while (my $line = <$in>) {
		$linecount++;
		chomp($line);
		my @arr = split("\t", $line);
		foreach my $arr (@arr) {
			my ($org, $kmer, $score) = $arr =~ /^(\w+)\.fa\_(\w+)\_(-{0,1}\d+\.*\d*)/i;
			die "die at $arr since not defined org\n" if not defined($org) or not defined($score);
			$kmer{$org}{'kmer'}{$kmer} = $score;
		}
	}
	$cache -> set("kmerdb_$Nmer", \%kmer);		
	close $in;
	return(\%kmer);
}
sub PROCESS_KMER_FAMILY {
	my ($family) = @_;
	my %kmer_total;
	foreach my $org (@{$org{$family}}) {
		print "$family\t$org\n";
		foreach my $kmer (keys %{$kmer{$org}{'kmer'}}) {
			my $score = $kmer{$org}{'kmer'}{$kmer};
			#print "ORG $org\tKMER $kmer\t$score\n";
			$kmer_total{'kmer'}{$kmer} += $score;
			$kmer_total{'number'}{$kmer} ++;
		}
	}
	my @kmer;
	foreach my $kmer (sort {$kmer_total{'number'}{$b} <=> $kmer_total{'number'}{$a}} keys %{$kmer_total{'number'}}) {
		my $number = $kmer_total{'number'}{$kmer};
		my $score = $kmer_total{'kmer'}{$kmer}/$number;
		push(@{$kmer[$number]}, [$kmer, $score]);
		#print "KMER $kmer\tKMER2 $kmer\tSCORE $score\tNUMBER $number\n";
	}
	my @kmerlist;
	for (my $i = @kmer-1; $i >= 0; $i--) {
		next if not defined($kmer[$i]);
		my @array = @{$kmer[$i]};
		@array = sort {$b->[1] <=> $a->[1]} @array;
		for (my $j = 0; $j < @array; $j++) {
			my ($kmer, $score) = ($array[$j][0], $array[$j][1]);
			next if $score > $MAX_KMER_SCORE;
			push(@kmerlist, [$kmer, $score, $i]);
		}
	}

#	foreach my $kmer (sort {$kmer_total{'kmer'}{$b} <=> $kmer_total{'kmer'}{$a}} keys %{$kmer_total{'kmer'}}) {
#		my $score = $kmer_total{'kmer'}{$kmer};
#		my @kmers;
#
#		last if @kmerlist == $MAX_KMER_COUNT;
#	}
	
	return(\@kmerlist);
}
