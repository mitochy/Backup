#!/usr/bin/perl

use strict; use warnings; use mitochy;

my ($input) = @ARGV;
die "usage: $0 <input>\n" unless @ARGV;

my ($folder, $name) = mitochy::getFilename($input, "folder");

open (my $in, "<", $input) or die "Cannot read from $input: $!\n";

my $CPG = 0;
my $CHG = 0;
my $CHH = 0;
my $total = 0;
while (my $line = <$in>) {
	chomp($line);
	next if $line =~ /#/;
	next if $line =~ />/;
	
	$total += length($line);

	#CpG
	while ($line =~ /CG/ig) {
		$CPG++;	
		$CHH--;
	}

	#CHG
	while ($line =~ /CAG/ig) {
		$CHG++;
		$CHH--;
	}
	while ($line =~ /CCG/ig) {
		$CHG++;
		$CHH--;
	}
	while ($line =~ /CTG/ig) {
		$CHG++;
		$CHH--;
	}

	#CHH
	while ($line =~ /C/ig) {
		$CHH++;
	}
}

close $in;

printf "
total = $total
CpG = $CPG (%.2f MB) - %.2f %%
CHG = $CHG (%.2f MB) - %.2f %%
CHH = $CHH (%.2f MB) - %.2f %%
", int($CPG/1000000), $CPG/$total*100, int($CHG/1000000), $CHG/$total*100, int($CHH/1000000), $CHH/$total*100;

