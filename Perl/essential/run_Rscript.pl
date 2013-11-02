#!/usr/bin/perl

use strict; use warnings;

my @Rscripts = @ARGV;
die "usage: run_Rscript.pl <files of R scripts>\n" unless @ARGV;

my @failed;
foreach my $Rscript (@Rscripts) {
	my $Rthis = "R --vanilla --no-save < $Rscript";
	system($Rthis) == 0 or (print "Warning: R failed to run: $!\n" and push(@failed, $Rthis));
}

print "Failed to run: \n";
foreach my $fail (@failed) {
	print "$fail\n";
}
