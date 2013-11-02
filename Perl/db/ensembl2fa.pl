#!/usr/bin/perl

use strict; use warnings; use mitochy;

my ($input) = @ARGV;
die "usage: biomart2fa.pl <biomart.seq>\n" unless @ARGV;
open (my $in, "<", $input) or die "Cannot read from $input: $!\n";
open (my $out, ">", "$input.fa") or die "Cannot write to $input.fa: $!\n";

while (my $line = <$in>) {
	chomp($line);
	$line =~ s/"//ig;
	next if $line !~ /^\d/i;
	my @arr = split(" ", $line);
	my $seq = $arr[1];
	my $def = $arr[2];
	print $out ">$def\n$seq\n";
}

close $in;
close $out;	
