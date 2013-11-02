#!/usr/bin/perl

use strict; use warnings; use mitochy;

die "usage: run_rmes_gauss.pl <.rmesinput> <scale (itoj) [optional]>\n" unless @ARGV;

#my @input;
#open (my $in, "<", "/Users/stella/Desktop/filelist.txt") or die;
#while (my $line = <$in>) {
#	chomp ($line);
#	push (@input, $line);
#}


my ($input, $scale) = @ARGV;
$scale = "2to8" if not defined($scale);
my ($lower, $upper) = $scale =~ /^(\d+)to(\d+)$/;

my $RMES = "rmes --gauss -s $input -o $input.rmes.gauss -i $lower -a $upper --max";
my $RMESF = "rmes.format -i $lower -a $upper --tmin 0 --tmax 0 < $input.rmes.gauss.0 > $input.rmes.gauss.table";
print "RMES $input\n";
system($RMES) == 0 or die "Failed to run RMES: $!\n";
print "RMES.format $input\n";
system($RMESF) == 0 or die "Failed to run RMES.FORMAT: $!\n";
