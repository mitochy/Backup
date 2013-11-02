#!/usr/bin/perl

use strict; use warnings; use mitochy;

my @input = @ARGV;

foreach my $input (@input) {
	my $RMES = "rmes --compoundpoisson -s $input -o $input.rmes.comppoisson -i 4 -a 8 --max";
	my $RMESF = "rmes.format -i 4 -a 8 < $input.rmes.comppoisson.0 > $input.rmes.comppoisson.table";
	print STDERR "RMES";
	system($RMES) == 0 or die "Failed to run RMES: $!\n";
	print STDERR "RMESFORMAT\n";
	system($RMESF) == 0 or die "Failed to run RMES.FORMAT: $!\n";
}