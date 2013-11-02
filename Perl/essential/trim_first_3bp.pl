#!/usr/bin/perl

use strict; use warnings;

my ($fastq, $output) = @ARGV;
die "usage: $0 <fastq> <output>\n" unless @ARGV == 2;

open (my $in, "<", $fastq) or die "Cannot read from $fastq: $!\n";
open (my $out, ">", $output) or die "Cannot write to $output: $!\n";
my $linecount = 0;
while (my $line = <$in>) {
	chomp($line);
	$linecount++;
	if ($line =~ /^\@HS/) {
		# Header
		print $out "$line\n";
		my $check = 0;
		
		# Next line/sequence line
		$line = <$in>;
		chomp($line);
		if ($line =~ /^CGG/ or $line =~ /^TGG/ or $line =~ /^NGG/) {
			($line) = $line =~ /^\w\w\w(\w+)$/;
			$check = 1;
		}
		print $out "$line\n";
		
		# Plus sign
		$line = <$in>;
		chomp($line);
		die if $line !~ /^\+$/;
		print $out "$line\n";

		# Quality
		$line = <$in>;
		chomp($line);
		if ($check == 1) {
			($line) = $line =~ /^...(.+)$/;
		}
		print $out "$line\n";
	}
	else {
		die "Died at $line\n";
	}
}	
close $in;
