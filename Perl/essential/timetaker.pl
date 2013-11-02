#!/usr/bin/perl

use strict; use warnings;

my $home = $ENV{'HOME'};
my $input = $ARGV[0];

open (my $in, "<", "$input") or die "Cannot open $input\n";
my ($dir, $filename) = $input =~ m/^(.+\/)(ecoli.+)\.*\.*\.ps.log$/ig;

open (my $out, ">", "$dir\_$filename\_memory.txt") or die "Cannot open output\n";

print $out "PID\tDATE\tTIME\tELAPSE\tCPU\tMEM\tRSS\tVSIZE\n";
my $count;
while (my $line = <$in>) {
	$count++;
	chomp($line);
#	print "$line\n";
	my ($PID, $date, $time, $elapse, $CPU, $MEM, $RSS, $VSIZE) = ($line =~ /^\s{1,100}(\d+)\s{1,100}(\d+\-\d+\-\d+)\s{1,100}(\d+\:\d+\:\d+)\s{1,100}(\d+\:\d+:*\d*)\s{1,100}(\d+\.*\d*)\s{1,100}(\d+\.\d+)\s{1,100}(\d+)\s{1,100}(\d+)/i);
	print $out "$PID\t$date\t$time\t$elapse\t$CPU\t$MEM\t$RSS\t$VSIZE\n" if $count != 1;
	
}

close $in;
close $out;
print "file name = $filename\n";