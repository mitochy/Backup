#!/usr/bin/perl

use strict; use warnings;

my ($input) = @ARGV;
die "usage: $0 <methylkit result>\n" unless @ARGV;

my $cmd = "perl -pi -e 's/^.+target.row.+\n//' $input";
system($cmd);
$cmd = "perl -pi -e 's/^.+qvalue.+\n//' $input";
system($cmd);
$cmd = "perl -pi -e 's/\\n/SPACESHIP/' $input";
system($cmd) == 0 or die "Failed to run: $cmd\n";
$cmd = "perl -pi -e 's/\\s+/\\t/g' $input";
system($cmd);
$cmd = "perl -pi -e 's/SPACESHIP/\\n/g' $input";
system($cmd);
