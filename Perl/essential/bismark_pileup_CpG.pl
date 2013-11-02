#!/usr/bin/perl

use strict; use warnings; use Getopt::Std; 
use List::Util qw(first max maxstr min minstr reduce shuffle sum);
use Statistics::Multtest qw(:all);

use vars qw($opt_c);
getopts("c:");


my (@input) = @ARGV;
die "usage: $0 [option] <TOP (_OT)> <BOTTOM (_OB)>\n\tWARNING: Result >>MUST<< be from methylation_extractor
options:
-c coverage at least (default: 1)
" unless @ARGV == 2;


my %data;
my $context = "CpG" if $input[0] =~ /CpG/;
$context = "CHG" if $input[0] =~ /CHG/;
$context = "CHH" if $input[0] =~ /CHH/;
my ($output) = $input[0] =~ /_OT_(\w+_\w+).fq/;
my $minCov = defined($opt_c) ? $opt_c : 1;

die "Died $input[0] because not defined output (make sure to put TOP then BOTTOM)\n" if not defined($output);

open (my $outbed, ">", "$output\_$context.bed") or die "Cannot write to $output.bed: $!\n";
open (my $outwig_covs, ">", "$output\_$context\_coverage.wig") or die "Cannot write to $output\_$context\_coverage.wig: $!\n";
open (my $outwig_meth, ">", "$output\_$context\_meth.wig") or die "Cannot write to $output\_$context\_meth.wig: $!\n";
open (my $outbedTOP, ">", "$output\_$context\_TOP.bed") or die "Cannot write to $output\_$context\_TOP.bed: $!\n";
open (my $outwig_covsTOP, ">", "$output\_$context\_TOP\_coverage.wig") or die "Cannot write to $output\_$context\_TOP_coverage.wig: $!\n";
open (my $outwig_methTOP, ">", "$output\_$context\_TOP\_meth.wig") or die "Cannot write to $output\_$context\_TOP_meth.wig: $!\n";
open (my $outbedBOT, ">", "$output\_$context\_BOT.bed") or die "Cannot write to $output\_$context\_BOTbed: $!\n";
open (my $outwig_covsBOT, ">", "$output\_$context\_BOT\_coverage.wig") or die "Cannot write to $output\_$context\_BOT_coverage.wig: $!\n";
open (my $outwig_methBOT, ">", "$output\_$context\_BOT\_meth.wig") or die "Cannot write to $output\_$context\_BOT_meth.wig: $!\n";

print $outbed "track name=\"$output\_$context\_bed\" description=\"$context strand_specific rrbs (min cov = $minCov) of mouse ESC of $output\" itemRgb=\"On\"\n";
print $outwig_covs "track type=wiggle_0 name=\"$output\_$context\_covs.wig\" description=\"$context strand_specific rrbs (min cov = $minCov) of mouse ESC of $output: coverage\"\n";
print $outwig_meth "track type=wiggle_0 name=\"$output\_$context\_meth.wig\" description=\"$context strand_specific rrbs (min cov = $minCov) of mouse ESC of $output: methylation\"\n";
print $outbedTOP "track name=\"$output\_$context\_TOP_bed\" description=\"$context strand_specific TOP rrbs (min cov = $minCov) of mouse ESC of $output\" itemRgb=\"On\"\n";
print $outwig_covsTOP "track type=wiggle_0 name=\"$output\_$context\_covs.wig\" description=\"$context strand_specific TOP rrbs (min cov = $minCov) of mouse ESC of $output: coverage\"\n";
print $outwig_methTOP "track type=wiggle_0 name=\"$output\_$context\_meth.wig\" description=\"$context strand_specific TOP rrbs (min cov = $minCov) of mouse ESC of $output: methylation\"\n";
print $outbedBOT "track name=\"$output\_$context\_BOT\_bed\" description=\"$context strand_specific BOT rrbs (min cov = $minCov) of mouse ESC of $output\" itemRgb=\"On\"\n";
print $outwig_covsBOT "track type=wiggle_0 name=\"$output\_$context\_BOT\_covs.wig\" description=\"$context strand_specific BOT rrbs (min cov = $minCov) of mouse ESC of $output: coverage\"\n";
print $outwig_methBOT "track type=wiggle_0 name=\"$output\_$context\_BOT\_meth.wig\" description=\"$context strand_specific BOT rrbs (min cov = $minCov) of mouse ESC of $output: methylation\"\n";

my $linecount = 0;

foreach my $input (@input) {
	my $strand = $input =~ /_OT_/ ? "+" : "-";
	open (my $in, "<", $input) or die "Cannot read from $input: $!\n";
	while (my $line = <$in>) {
		chomp($line);
		$linecount++;
		print "Processed $linecount\n" if $linecount % 5000000 == 0;
		next if $line =~ /Bismark methylation extractor/;
		my ($name, $junk, $chr, $pos, $meth) = split("\t", $line);
		#die "Died at $line\n" if $meth ne "Z" and $meth ne "z";
		push(@{$data{$chr}{$pos}{meth}},1) if $meth eq "Z";# or $meth eq "X" or $meth eq "H";
		push(@{$data{$chr}{$pos}{meth}},0) if $meth eq "z";# or $meth eq "x" or $meth eq "h";
		push(@{$data{$chr}{$pos}{meth}},1) if $meth eq "X";# or $meth eq "X" or $meth eq "H";
		push(@{$data{$chr}{$pos}{meth}},0) if $meth eq "x";# or $meth eq "x" or $meth eq "h";
		push(@{$data{$chr}{$pos}{meth}},1) if $meth eq "H";# or $meth eq "X" or $meth eq "H";
		push(@{$data{$chr}{$pos}{meth}},0) if $meth eq "h";# or $meth eq "x" or $meth eq "h";
		$data{$chr}{$pos}{covs}   ++;
		$data{$chr}{$pos}{strand}  = $strand;
	}
	close $in;
}

my $read_lower_than_minCov = 0;
my $total_read 		   = 0;
foreach my $chr (sort keys %data) {
	print $outwig_covs "variableStep chrom=$chr span=1\n";
	print $outwig_meth "variableStep chrom=$chr span=1\n";
	print $outwig_covsTOP "variableStep chrom=$chr span=1\n";
	print $outwig_methTOP "variableStep chrom=$chr span=1\n";
	print $outwig_covsBOT "variableStep chrom=$chr span=1\n";
	print $outwig_methBOT "variableStep chrom=$chr span=1\n";
	foreach my $pos (sort {$a <=> $b} keys %{$data{$chr}}) {
		my $end    = $pos + 1;
		my @meth   = @{$data{$chr}{$pos}{meth}};
		my $meth   = sum(@meth);
		my $covs   = $data{$chr}{$pos}{covs};
		my $strand = $data{$chr}{$pos}{strand};
		my $ratio  = defined($covs) ? $meth / $covs * 100 : 0;
		my $red    = int($ratio/100 * 255);
		my $blue   = int((100-$ratio)/100 * 255);
		my $color  = "$red,0,$blue";
		if ($covs >= $minCov) {
			print $outbed "$chr\t$pos\t$end\t$context\_$covs\_$ratio\t$covs\t$strand\t$pos\t$end\t$color\n";
			print $outwig_covs "$pos\t$covs\n";
			print $outwig_meth "$pos\t$ratio\n";
			if ($strand eq "+") {
				print $outbedTOP "$chr\t$pos\t$end\t$context\_$covs\_$ratio\t$covs\t$strand\t$pos\t$end\t$color\n";
				print $outwig_covsTOP "$pos\t$covs\n";
				print $outwig_methTOP "$pos\t$ratio\n";
			}
			elsif ($strand eq "-") {
				print $outbedBOT "$chr\t$pos\t$end\t$context\_$covs\_$ratio\t$covs\t$strand\t$pos\t$end\t$color\n";
				print $outwig_covsBOT "$pos\t$covs\n";
				print $outwig_methBOT "$pos\t$ratio\n";
			}
		}
		else {
			$read_lower_than_minCov++;
		}
		$total_read++;
	}
}
my $percent_read_lower_than_minCov = $read_lower_than_minCov / $total_read * 100;
print "$input[0]: Reads not used = $read_lower_than_minCov ($percent_read_lower_than_minCov % of total $total_read)\n";
