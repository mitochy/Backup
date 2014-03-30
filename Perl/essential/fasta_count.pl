#!/usr/bin/perl

use strict; use warnings; use mitochy;

my ($fasta) = @ARGV;
die "usage: $0 <fasta>\n" unless @ARGV;
