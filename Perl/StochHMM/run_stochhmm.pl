#!/usr/bin/perl

use strict; use warnings; use mitochy;

my ($input, $model, $threshold) = @ARGV;
die "usage: $0 <input> <model> <threshold>\n" unless @ARGV;
my ($folder, $name) = mitochy::get_filename($input);
print "$folder NAME $name\n";
my $cmd = "stochhmm -seq $input -model $model -posterior -threshold $threshold > $input.prob";
print "$cmd\n";
system($cmd);
