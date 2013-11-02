#!/usr/bin/perl

use strict; use warnings;

my ($input, $output) = @ARGV;
die "usage: $0 <input from methratio.py> <output (name)>\n" unless @ARGV == 2;

open (my $in, "<", $input) or die "Cannot read from $input: $!\n";
open (my $outbed, ">", "$output\.bed") or die "Cannot write to $output\.bed: $!\n";
open (my $outwig, ">", "$output\.wig") or die "Cannot write to $output\.wig: $!\n";
open (my $outwigcov, ">", "$output\_coverage.wig") or die "Cannot write to $output\_coverage.wig: $!\n";
print $outbed "track name=\"$output\_methbed\" itemRgb=\"On\"\n";
print $outwig "track type=wiggle_0 name=\"$output\_methwig\"\n";
print $outwigcov "track type=wiggle_0 name=\"$output\_coverage\"\n";
my $curr_chr = "INIT";
my @header;
while (my $line = <$in>) {
	chomp($line);
	next if ($line =~ /chr\tpos\tstrand/);
	my ($chr, $pos, $strand, $name, $ratio, $total_c, $methyl_c) = split("\t", $line);
	my $end = $pos + 1;
	my $methylated = $methyl_c / $total_c * 100;
	# CG
	my $red = int($methylated * 255);
	my $blue = int((1-$methylated) * 255);
	my $color = "$red,0,$blue";

	if (($strand eq "+" and $name =~ /^\w\wCG\w$/) or ($strand eq "-" and $name =~ /^\wCG\w\w$/)) {
		print $outbed "$chr\t$pos\t$end\tCG_$name\_$total_c\t$methylated\t$strand\t$pos\t$end\t$color\n";
		if ($curr_chr ne $chr) {
			print $outwig "variableStep chrom=$chr span=1\n";
			print $outwigcov "variableStep chrom=$chr span=1\n";
			$curr_chr = $chr;
		}
		print $outwig "$pos\t$methylated\n";
		print $outwigcov "$pos\t$total_c\n";
	}

	# CHG
	#elsif (($strand eq "+" and $name =~ /^\w\wC\wG$/) or ($strand eq "-" and $name =~ /^C\wG\w\w$/)) {
		#print $outbed "$chr\t$pos\t$end\tCHG_$name\_$total_c\t$methylated\t$strand\t$pos\t$end\t$color\n";
		#if ($curr_chr ne $chr) {
			#print $outwig "variableStep chrom=$chr span=1\n";
			#print $outwigcov "variableStep chrom=$chr span=1\n";
			#$curr_chr = $chr;
		#}
		#print $outwig "$pos\t$methylated\n";
		#print $outwigcov "$pos\t$total_c\n";
	#}

	# CHH
	#elsif (($strand eq "+" and $name =~ /^\w\wC\w\w$/) or ($strand eq "-" and $name =~ /^\w\wG\w\w$/)) {
		#print $outbed "$chr\t$pos\t$end\tCHH_$name\_$total_c\t$methylated\t$strand\t$pos\t$end\t$color\n";
		#if ($curr_chr ne $chr) {
			#print $outwig "variableStep chrom=$chr span=1\n";
			#print $outwigcov "variableStep chrom=$chr span=1\n";
		#	$curr_chr = $chr;
		#}
		#print $outwig "$pos\t$methylated\n";
		#print $outwigcov "$pos\t$total_c\n";
	#}
}
close $in;
close $outbed;
close $outwig;
close $outwigcov;
