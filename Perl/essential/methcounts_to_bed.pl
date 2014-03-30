#!/usr/bin/perl

use strict; use warnings; use mitochy;

my ($input) = @ARGV;
die "usage: $0 <input>\n" unless @ARGV;

my ($folder, $name) = mitochy::getFilename($input, "folder");

open (my $in, "<", $input) or die "Cannot read from $input: $!\n";
open (my $out, ">", "$name.bed") or die "Cannot write to $name.bed: $!\n";

while (my $line = <$in>) {
	chomp($line);
	next if $line =~ /#/;
	next if $line =~ /track/;
	my ($chr, $start, $strand, $context, $meth, $cov) = split("\t", $line);
	$meth = $meth * 100;
	my $end = $start + 1;
	my $name = "$context\_$cov\_$meth";
	print $out "$chr\t$start\t$end\t$name\t$cov\t$strand\n";
}

close $in;
close $out;
