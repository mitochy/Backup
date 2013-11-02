#!/usr/bin/perl

use strict; use warnings; use mitochy;

my @input = @ARGV;

die "usage: script.pl rmes_compare_result(s)\n" unless @ARGV;


foreach my $input (@input) {
	print STDERR "processing $input\n";
	open (my $in, "<", $input) or die;
	my $linecount = 0;
	my %org;
	my ($ntax, @animals);
	while (my $line = <$in>) {
		chomp($line);
		$linecount++ unless $linecount == 2;
		my @arr = split("\t",$line);

		if ($linecount == 1) {
			($ntax, @animals) = @arr;
			next;
		}
		
		my ($kmer, @scores) = @arr;
		
		for (my $i = 0; $i < @scores; $i++) {
			$org{$animals[$i]}{$kmer} = $scores[$i];
		}
	}
	
	my @matrix;
	my ($count1) = (-1);
	my $lowest_matrix = 9999999;
	foreach my $animal (sort keys %org) {
		my $key = (keys %{$org{$animal}});
		print "key = $key\n";
		$count1++;
		print "$count1 $animal: ";
		my $count2 = -1;
		foreach my $animal2 (sort keys %org) {
			$count2++;
			print "$animal2 ";
			my $included = 0;
			foreach my $kmer (sort keys %{$org{$animal}}) {
				#print "distance = $animal - $animal2\n";
				my $kmer1 = $org{$animal}{$kmer};
				$kmer1 = $kmer1 < 0 ? -1 *$kmer1 *$kmer1 : $kmer1*$kmer1;
				my $kmer2 = $org{$animal2}{$kmer};
				$kmer2 = $kmer2 < 0 ? -1 *$kmer2 *$kmer2 : $kmer2*$kmer2;
				my $distance = sqrt(abs($kmer1-$kmer2));
				$distance = 0 if $distance =~ /inf/;
				$distance = 0 if $distance =~ /nan/;
				$matrix[$count1][$count2] += $distance;
				$included++;
			}
			my $last = $matrix[$count1][$count2];
			$matrix[$count1][$count2] = $included == 0 ? 0 : $matrix[$count1][$count2]/$included;
			$lowest_matrix = $matrix[$count1][$count2] if $lowest_matrix > $matrix[$count1][$count2] and $matrix[$count1][$count2] != 0;
			last if $count2 == $count1;
			die "$last\t$count2\n" if $matrix[$count1][$count2] =~ /inf/;
			die "$last\t$count2\n" if $matrix[$count1][$count2] =~ /nan/;
		}
		print "\n";
	}
	my $key = @matrix;
	#print "keys = $key\n";
	
	open (my $out, ">", "$input.distancematrix.txt") or die "Cannot write to output; $!\n";
	
	
	for (my $i = 0; $i < @matrix; $i++) {
		print $out "$animals[$i] ";
		for (my $j = 0; $j < @{$matrix[$i]}; $j++) {
			my $matrixes = $matrix[$i][$j] != 0 ? $matrix[$i][$j]-(0.99*$lowest_matrix) : 0;
			print $out "$matrixes ";
		}
		print $out "\n";
	}
	close $out;
}














__END__
	print "\#nexus
begin taxa;
";
	open (my $in, "<", $input) or die;
	my $linecount = 0;
	while (my $line = <$in>) {
		$linecount++;
		my @arr = split("\t",$line);
		if ($linecount == 1) {
			my ($ntax, @taxon) = @arr;
			print "\tdimensions ntax=$ntax\;\ntaxlabels ";
			for (my $i = 0; $i < @taxon; $i++) {
				print "$taxon[$i] ";
			}
			print "\nend\;\n\nbegin distances\;\n\tdimensions ntax=$ntax\;\n\tformat diagonal labels triangle=lower\;\n\tmatrix";
		}		
	
	close $in;
