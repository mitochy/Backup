#!/usr/bin/perl

use strict; use warnings; use mitochy;

my ($input) = @ARGV;
die "usage: R_biomart_IDtrimmer.pl <R_biomart_getsequence ID result.ID>\n" unless @ARGV;

open (my $in, "<", $input) or die "Cannot read from $input: $!\n";
open (my $out, ">", "$input.new.ID") or die "Cannot write to $input.new.ID: $!\n";
my %ID;
my %checkID;
my $number = 0;
while (my $line = <$in>) {
	chomp($line);
	print $out "$line\n" if $line =~ /^"V1"/;
	next if $line =~ /^"V1"/;
	my @arr = split(" ", $line);
	my ($human, $org) = ($arr[1], $arr[2]);
	next if exists($checkID{$human});
	$checkID{$human}++;
	print $out "$line\n";
	$ID{$number}{$human} = $org;
	#print "arr0 = $arr[0], arr1 = $arr[1], arr2 = $arr[2]\n";
}	

close $in;
close $out;

