#!/usr/bin/perl

use strict; use warnings; use mitochy;

my ($input) = @ARGV;
die "usage: $0 <input>\n" unless @ARGV;

my ($folder, $name) = mitochy::getFilename($input, "folder");

open (my $in, "<", $input) or die "Cannot read from $input: $!\n";
open (my $out, ">", "$name.meth") or die "Cannot write to $name.meth: $!\n";

while (my $line = <$in>) {
	chomp($line);
	next if $line =~ /#/;
	next if $line =~ /track/;
	my @arr = split("\t", $line);
	my ($context, $cov, $meth) = split("_", $arr[3]);
	$meth = int($meth*100) / 10000;
	print $out "$arr[0]\t$arr[1]\t$arr[5]\t$context\t$meth\t$cov\n";
}

close $in;
close $out;
