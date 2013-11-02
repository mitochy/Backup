#!/usr/bin/perl

use strict; use warnings; use mitochy;

my ($input, $mode, $kmer_l) = @ARGV;
die "usage: get_kmer.pl <rmes compare output .logodd.txt> <mode: 1 for by kmer, 2 for by org> <length kmer [default: all]>\n" unless @ARGV;
$mode = 1 if not defined($mode);

#my @organism = qw (acarolinensis amelanoleuca btaurus celegans cfamiliaris choffmanni cintestinalis cjacchus cporcellus csavignyi dmelanogaster dnovemcinctus dordii drerio ecaballus eeuropaeus etelfairi fcatus gaculeatus ggallus ggorilla gmorhua hsapiens lafricana lchalumnae mdomestica meugenii mgallopavo mlucifugus mmulatta mmurinus mmusculus nleucogenys oanatinus ocuniculus ogarnettii olatipes oprinceps pabelii pcapensis pmarinus ptroglodytes pvampyrus rnorvegicus saraneus scerevisiae sharrisii sscrofa stridecemlineatus tbelangeri tguttata tnigroviridis trubripes tsyrichta ttruncatus vpacos xtropicalis);
open (my $in, "<", $input) or die "Cannot read from $input: $!\n";

my @org;
my %kmer;
my %org;
my $linecount = 0;
while (my $line = <$in>) {
	chomp($line);
	$linecount++;
	my @arr = split("\t", $line);
	
	#Header
	if ($linecount == 1) {
		for (my $i = 1; $i < @arr; $i++) {
			$org[$i] = $arr[$i];
		}
		next;
	}
	
	#Main
	my $kmer = $arr[0];
	next if defined($kmer_l) and length($kmer) < $kmer_l;
	for (my $i = 1; $i < @arr; $i++) {
		$kmer{'kmer'}{$kmer}{$org[$i]} = $arr[$i];
		$kmer{'org'} {$org[$i]}{$kmer} = $arr[$i];
	}
}

print "Done processing file: next\n";
#Sort by kmer
if ($mode == 1) {
	foreach my $kmer (sort keys %{$kmer{'kmer'}}) {
		if (not defined($kmer_l)) {
			#print "$kmer\t";
			foreach my $org (sort keys %{$kmer{'kmer'}{$kmer}}) {
				my $score = $kmer{'kmer'}{$kmer}{$org};
				#print "$org_$score\t";
			}
		}
		elsif (defined($kmer_l)) {
			next if length($kmer) != $kmer_l;
			#print "$kmer\t";
		}
			
	}
}
		
#Sort by organism's logodd score
if ($mode == 2) {
	print "processing logodd score\n";
	my @array;
	my $count_x = -1;
	foreach my $org (sort keys %{$kmer{'org'}}) {
		$count_x ++;
		my $count_y = -1;
		foreach my $kmer(sort {$kmer{'org'}{$org}{$b} <=> $kmer{'org'}{$org}{$a}} keys %{$kmer{'org'}{$org}}) {
			next if (defined($kmer_l) and length($kmer) != $kmer_l);
			$count_y ++;
			my $score = $kmer{'org'}{$org}{$kmer};
			$array[$count_x][$count_y] = "$org\_$kmer\_$score";
			#print "\$array $count_x $count_y = \"$org\_$kmer\_$score\"\n";
		}
	}
	my $output = "$input.org.sort.txt";
	$output = "$input.org.sort.$kmer_l.txt" if defined($kmer_l);	
	open (my $out, ">", $output) or die "Cannot write to $input.org.sort.txt: $!\n";
	for (my $i = 0; $i < @{$array[0]}; $i++) {
		for (my $j = 0; $j < @array; $j++) {
			next if not defined($array[$j][$i]);
			print $out "$array[$j][$i]\t";
		}
		print $out "\n";
	}
}
close $in;
