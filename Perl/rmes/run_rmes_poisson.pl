#!/usr/bin/perl

use strict; use warnings; use mitochy;

my @input = @ARGV;

foreach my $input (@input) {
	my $RMES = "rmes --poisson -s $input -o $input.rmes.poisson -i 4 -a 8 --max";
	my $RMESF = "rmes.format -i 4 -a 8 < $input.rmes.poisson.0 > $input.rmes.poisson.table";
	print STDERR "RMES";
	system($RMES) == 0 or die "Failed to run RMES: $!\n";
	print STDERR "RMESFORMAT\n";
	system($RMESF) == 0 or die "Failed to run RMES.FORMAT: $!\n";
}