#!/usr/bin/perl

use strict; use warnings;

my ($input) = @ARGV;

die "usage: $0 <question>\n" unless @ARGV;

print "use fastq-dump\n" if $input =~ /sra/i;
