#!/usr/bin/perl

use strict; use warnings FATAL => 'all'; use mitochy; use Cache::FileCache;

print "
usage: my \%transfac{\$name}{\$type} = \$value\;
DE is Description of gene or gene product, gene accession number
TY is Sequence type (DNA/RNA)
ID is the identifier (gene name)
SQ is the sequence of the regulatory element
OC is the organism classification
OS it the organism species

";

my $cache = new Cache::FileCache();
$cache -> set_cache_root("/home/mitochi/Desktop/Cache");

my $input = "/home/mitochi/Desktop/Work/transfac/transfac.db";
open (my $in, "<", $input) or die "Cannot read from $input: $!\n";

my %hash;
while (my $line = <$in>) {
	chomp($line);
	my ($name, @arr) = split("\t", $line);
	for (my $i = 0; $i < @arr; $i++) {
		my ($type, $value) = $arr[$i] =~ /^(\w\w)=(.+)$/;
		$hash{$name}{$type} = $value;
	}
}
close $in;

$cache -> set("transfac", \%hash);

print "
use Cache::FileCache;
my \$cache = new Cache\:\:FileCache()\;
\$cache -> set_cache_root(\"\/home\/mitochi\/Desktop\/Cache\")\;
my \$transfac = \%\{\$cache -> get(\"transfac\")}\;

";
