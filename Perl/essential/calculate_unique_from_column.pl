#!/usr/bin/perl

use strict; use warnings; use mitochy;

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

my $count = (keys %data);
print "$input: $count\n";
my $name = mitochy::getFilename($input);
open (my $out, ">", "$name.genes") or die;
foreach my $name (sort {$data{$b} <=> $data{$a} or $a cmp $b} keys %data) {
	print $out "$name\t$data{$name}\n";
}
close $out;
	
