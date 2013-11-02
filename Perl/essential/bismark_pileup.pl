#!/usr/bin/perl

use strict; use warnings;

my ($input) = @ARGV;
die "usage: $0 <TOP (_OT) OR BOTTOM (_OB)>\n\tWARNING: Result >>MUST<< be from methylation_extractor\n" unless @ARGV == 1;
open (my $in, "<", $input) or die "Cannot read from $input: $!\n";
my %data;
my $strand = $input =~ /OT/ ? "+" : "-";
my $namestrand = $input =~ /OT/ ? "TOP" : "BOT";
my $context = $input =~ /CpG/ ? "CpG" : $input =~ /CHG/ ? "CHG" : "CHH";
my ($output) = $input =~ /_O\w_(\w+_\w+).fq/;

die "Died $input because not defined output\n" if not defined($output);

open (my $outbed, ">", "$output\_$context\_$namestrand.bed") or die "Cannot write to $output\_$context\_$namestrand.bed: $!\n";
open (my $outwig_covs, ">", "$output\_$context\_$namestrand\_coverage.wig") or die "Cannot write to $output\_$context\_$namestrand\_coverage.wig: $!\n";
open (my $outwig_meth, ">", "$output\_$context\_$namestrand\_meth.wig") or die "Cannot write to $output\_$context\_$namestrand\_meth.wig: $!\n";

print $outbed "track name=\"$output\_$context\_$namestrand.bed\" description=\"$context $namestrand strand_specific rrbs of mouse ESC of $output\" itemRgb=\"On\"\n";
print $outwig_covs "track type=wiggle_0 name=\"$output\_$context\_$namestrand\_covs.wig\" description=\"$context $namestrand strand_specific rrbs of mouse ESC of $output: coverage\"\n";
print $outwig_meth "track type=wiggle_0 name=\"$output\_$context\_$namestrand\_meth.wig\" description=\"$context $namestrand strand_specific rrbs of mouse ESC of $output: methylation\"\n";

my $linecount = 0;

while (my $line = <$in>) {
	chomp($line);
	$linecount++;
	print "Processed $linecount\n" if $linecount % 5000000 == 0;
	next if $line =~ /Bismark methylation extractor/;
	my ($name, $junk, $chr, $pos, $meth) = split("\t", $line);
	$data{$chr}{$pos}{meth} += 1 if $meth eq "Z" or $meth eq "X" or $meth eq "H";
	$data{$chr}{$pos}{meth} += 0 if $meth eq "z" or $meth eq "x" or $meth eq "h";
	$data{$chr}{$pos}{covs} ++;
}
close $in;

foreach my $chr (sort keys %data) {
	print $outwig_covs "variableStep chrom=$chr span=1\n";
	print $outwig_meth "variableStep chrom=$chr span=1\n";
	foreach my $pos (sort {$a <=> $b} keys %{$data{$chr}}) {
		my $end = $pos + 1;
		my $meth = $data{$chr}{$pos}{meth};
		my $covs = $data{$chr}{$pos}{covs};
		my $ratio = defined($covs) ? $meth / $covs * 100 : 0;
		my $red  = int($ratio/100 * 255);
		my $blue = int((100-$ratio)/100 * 255);
		my $color = "$red,0,$blue";
		print $outbed "$chr\t$pos\t$end\t$context\_$covs\_$ratio\t$covs\t$strand\t$pos\t$end\t$color\n";
		print $outwig_covs "$pos\t$covs\n";
		print $outwig_meth "$pos\t$ratio\n";
	}
}
