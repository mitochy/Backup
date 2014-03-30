#!/usr/bin/perl

use strict; use warnings; use Getopt::Std; use mitochy;
use List::Util qw(first max maxstr min minstr reduce shuffle sum);
use Statistics::Multtest qw(:all);

use vars qw($opt_c $opt_o);
getopts("c:o:");


my ($input) = @ARGV;
die "usage: $0 [option] <methylation extractor output file (TOP (OT_) -or- <BOTTOM (OB_)>\n\tWARNING: Result >>MUST<< be from methylation_extractor
options:
-c minimum coverage (at least 1, default = 1)
-o Directory of output
" unless @ARGV == 1;

my $input2 = $input;
$input2 =~ s/_OT_/_OB_/;
$input2 =~ s/_CTOT_/_CTOB_/;
my @input = ($input, $input2);

my %data;
my $context;
$context = "CpG" if $input =~ /CpG/;
$context = "CHG" if $input =~ /CHG/;
$context = "CHH" if $input =~ /CHH/;
my ($folder, $inputName) = mitochy::getFilename($input, "folder");
$folder = $opt_o if defined($opt_o);
$folder = "./" if $folder !~ /^.+$/;
my $minCov = defined($opt_c) ? $opt_c : 1;
$minCov = 1 if $minCov < 1;

open (my $outbed, ">", "$folder\/$inputName\_$context.bed") or die "Cannot write to $folder\/$inputName.bed: $!\n";
open (my $outwig_covs, ">", "$folder\/$inputName\_$context\_coverage.wig") or die "Cannot write to $folder\/$inputName\_$context\_coverage.wig: $!\n";
open (my $outwig_meth, ">", "$folder\/$inputName\_$context\_meth.wig") or die "Cannot write to $folder\/$inputName\_$context\_meth.wig: $!\n";
open (my $outbedTOP, ">", "$folder\/$inputName\_$context\_TOP.bed") or die "Cannot write to $folder\/$inputName\_$context\_TOP.bed: $!\n";
open (my $outwig_covsTOP, ">", "$folder\/$inputName\_$context\_TOP\_coverage.wig") or die "Cannot write to $folder\/$inputName\_$context\_TOP_coverage.wig: $!\n";
open (my $outwig_methTOP, ">", "$folder\/$inputName\_$context\_TOP\_meth.wig") or die "Cannot write to $folder\/$inputName\_$context\_TOP_meth.wig: $!\n";
open (my $outbedBOT, ">", "$folder\/$inputName\_$context\_BOT.bed") or die "Cannot write to $folder\/$inputName\_$context\_BOTbed: $!\n";
open (my $outwig_covsBOT, ">", "$folder\/$inputName\_$context\_BOT\_coverage.wig") or die "Cannot write to $folder\/$inputName\_$context\_BOT_coverage.wig: $!\n";
open (my $outwig_methBOT, ">", "$folder\/$inputName\_$context\_BOT\_meth.wig") or die "Cannot write to $folder\/$inputName\_$context\_BOT_meth.wig: $!\n";

print $outbed "track name=\"$inputName\_$context\_bed\" description=\"$context strand_specific rrbs (min cov = $minCov) of mouse ESC of $inputName\" itemRgb=\"On\"\n";
print $outwig_covs "track type=wiggle_0 name=\"$inputName\_$context\_covs.wig\" description=\"$context strand_specific rrbs (min cov = $minCov) of mouse ESC of $inputName: coverage\"\n";
print $outwig_meth "track type=wiggle_0 name=\"$inputName\_$context\_meth.wig\" description=\"$context strand_specific rrbs (min cov = $minCov) of mouse ESC of $inputName: methylation\"\n";
print $outbedTOP "track name=\"$inputName\_$context\_TOP_bed\" description=\"$context strand_specific TOP rrbs (min cov = $minCov) of mouse ESC of $inputName\" itemRgb=\"On\"\n";
print $outwig_covsTOP "track type=wiggle_0 name=\"$inputName\_$context\_covs.wig\" description=\"$context strand_specific TOP rrbs (min cov = $minCov) of mouse ESC of $inputName: coverage\"\n";
print $outwig_methTOP "track type=wiggle_0 name=\"$inputName\_$context\_meth.wig\" description=\"$context strand_specific TOP rrbs (min cov = $minCov) of mouse ESC of $inputName: methylation\"\n";
print $outbedBOT "track name=\"$inputName\_$context\_BOT\_bed\" description=\"$context strand_specific BOT rrbs (min cov = $minCov) of mouse ESC of $inputName\" itemRgb=\"On\"\n";
print $outwig_covsBOT "track type=wiggle_0 name=\"$inputName\_$context\_BOT\_covs.wig\" description=\"$context strand_specific BOT rrbs (min cov = $minCov) of mouse ESC of $inputName: coverage\"\n";
print $outwig_methBOT "track type=wiggle_0 name=\"$inputName\_$context\_BOT\_meth.wig\" description=\"$context strand_specific BOT rrbs (min cov = $minCov) of mouse ESC of $inputName: methylation\"\n";

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
		$data{$chr}{$pos}{meth} += 1 if $meth eq "Z";# or $meth eq "X" or $meth eq "H";
		$data{$chr}{$pos}{meth} += 0 if $meth eq "z";# or $meth eq "x" or $meth eq "h";
		$data{$chr}{$pos}{meth} += 1 if $meth eq "X";# or $meth eq "X" or $meth eq "H";
		$data{$chr}{$pos}{meth} += 0 if $meth eq "x";# or $meth eq "x" or $meth eq "h";
		$data{$chr}{$pos}{meth} += 1 if $meth eq "H";# or $meth eq "X" or $meth eq "H";
		$data{$chr}{$pos}{meth} += 0 if $meth eq "h";# or $meth eq "x" or $meth eq "h";
		#push(@{$data{$chr}{$pos}{meth}},1) if $meth eq "Z";# or $meth eq "X" or $meth eq "H";
		#push(@{$data{$chr}{$pos}{meth}},0) if $meth eq "z";# or $meth eq "x" or $meth eq "h";
		#push(@{$data{$chr}{$pos}{meth}},1) if $meth eq "X";# or $meth eq "X" or $meth eq "H";
		#push(@{$data{$chr}{$pos}{meth}},0) if $meth eq "x";# or $meth eq "x" or $meth eq "h";
		#push(@{$data{$chr}{$pos}{meth}},1) if $meth eq "H";# or $meth eq "X" or $meth eq "H";
		#push(@{$data{$chr}{$pos}{meth}},0) if $meth eq "h";# or $meth eq "x" or $meth eq "h";
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
		my $meth   = $data{$chr}{$pos}{meth};
		my $covs   = $data{$chr}{$pos}{covs};
		my $strand = $data{$chr}{$pos}{strand};
		my $ratio  = defined($covs) ? $meth / $covs * 100 : "NA";
		my $red    = int($ratio/100 * 255);
		my $blue   = int((100-$ratio)/100 * 255);
		my $color  = "$red,0,$blue";
		if ($covs >= $minCov) {
			print $outbed "$chr\t$pos\t$end\t$context\_coverage$covs\t$ratio\t$strand\t$pos\t$end\t$color\n";
			print $outwig_covs "$pos\t$covs\n";
			print $outwig_meth "$pos\t$ratio\n";
			if ($strand eq "+") {
				print $outbedTOP "$chr\t$pos\t$end\t$context\_coverage$covs\t$ratio\t$strand\t$pos\t$end\t$color\n";
				print $outwig_covsTOP "$pos\t$covs\n";
				print $outwig_methTOP "$pos\t$ratio\n";
			}
			elsif ($strand eq "-") {
				print $outbedBOT "$chr\t$pos\t$end\t$context\_coverage$covs\t$ratio\t$strand\t$pos\t$end\t$color\n";
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
print "$input: Reads not used = $read_lower_than_minCov ($percent_read_lower_than_minCov % of total $total_read)\n";
