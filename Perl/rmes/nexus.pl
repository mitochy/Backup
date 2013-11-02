#!/usr/bin/perl

use strict; use warnings; use mitochy;

my @input = @ARGV;
die "usage: nexus.pl <make_distance_matrix.pl result file>\n" unless @ARGV;
foreach my $input (@input) {
	my (@animal, $ani_count);
	open (my $out, ">", "$input.dblock.txt") or die;
	open (my $in2, "<", $input) or die;
	while (my $line = <$in2>) {
		chomp($line);
		my @arr = split(" ", $line);
		my $animal = $arr[0];
		push (@animal, $animal);
	}
	close $in2;
	$ani_count = @animal;
	
	#Print out nexus format
	print $out "\#nexus

begin taxa\;
	dimensions ntax=$ani_count\;
	taxlabels @animal\;
end\;

begin distances\;
	dimensions ntax=$ani_count\;
	format diagonal labels triangle=lower\;
	matrix\n";
	
	open (my $in, "<", $input) or die;
	while (my $line = <$in>) {
		chomp($line);
		print $out "\t\t$line\n";
		print STDERR "Warning: nan detected at $line: (changing to 0)\n" if $line =~ /nan/i;
		print STDERR "Warning: inf detected at $line: (changing to 0)\n" if $line =~ /inf/i;

		$line =~ s/nan/0/ig;
		$line =~ s/inf/0/ig;
	}
	print $out "\t\;
end\;";
	close $in;
}
