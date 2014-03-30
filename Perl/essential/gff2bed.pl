#!/usr/bin/perl

use strict; use warnings; use mitochy;

my ($input) = @ARGV;
die "usage: $0 <input>\n" unless @ARGV;

my ($folder, $name) = mitochy::getFilename($input, "folder");

open (my $in, "<", $input) or die "Cannot read from $input: $!\n";
open (my $out, ">", "$name.bed") or die "Cannot write to $name.bed: $!\n";

my %gene;
my ($total, $proteinCodingCount) = (0,0);
while (my $line = <$in>) {
	chomp($line);
	next if $line =~ /#/;
	my @arr = split("\t", $line);
	next if $line !~ /gene\t/;
	my ($chr, $start, $end, $names, $strand) = ($arr[0], $arr[3], $arr[4], $arr[8], $arr[6]);

	# Post process name into gene ID
	my @name = split(";", $names);
	undef($names);
	my $biotype;
	foreach my $name (@name) {
		($names) = $name =~ /^ID=(.+)$/ 	if $name =~ /^ID/;
		($biotype) = $name =~ /^biotype=(.+)$/  if $name =~ /biotype/;
	}
	$biotype = "unknown" if not defined($biotype);
	die "Undefined name at $line\n" unless defined($names);
	
	my $gene = "$chr\t$start\t$end\t$names\t$biotype\t$strand";
	# Store
	$gene{$chr}{$start}{$names} = $gene;
}

foreach my $chr (sort keys %gene) {
	foreach my $start (sort {$a <=> $b} keys %{$gene{$chr}}) {
		foreach my $names (sort keys %{$gene{$chr}{$start}}) {
			my $gene = $gene{$chr}{$start}{$names};
			$total++;
			$proteinCodingCount++ if $gene =~ /protein.*coding/i;
			print $out "$gene\n";
		}
	}
}
print "$input: Total = $total\tProtein Coding = $proteinCodingCount\n";
close $in;
close $out;
