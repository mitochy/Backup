#!/usr/bin/perl

use strict; use warnings; use mitochy;

my ($input) = @ARGV;
die "usage: $0 <input>\n" unless @ARGV;

my ($folder, $name) = mitochy::getFilename($input, "folder");

open (my $in, "<", $input) or die "Cannot read from $input: $!\n";
open (my $out, ">", "$name.out") or die "Cannot write to $name.out: $!\n";

my %line;
while (my $line = <$in>) {
	chomp($line);
	next if $line =~ /#/;
	$line{$line} = 1;
}

foreach my $line (sort keys %line) {
	print $out "$line\n";
}

close $in;
close $out;
