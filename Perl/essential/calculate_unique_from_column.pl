#!/usr/bin/perl

use strict; use warnings;

my ($input, $column) = @ARGV;
die "usage: $0 <input> <column (start from 0)\n" unless @ARGV == 2;

my %data;
open (my $in, "<", $input) or die "Cannot read from $input: $!\n";
while (my $line = <$in>) {
	chomp($line);
	my @arr = split("\t", $line);
	$data{$arr[$column]}++;
}
close $in;

foreach my $name (sort {$data{$b} <=> $data{$a}} keys %data) {
	print "$name\t$data{$name}\n";
}
	
