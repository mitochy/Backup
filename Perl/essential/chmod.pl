#!/usr/bin/perl

use strict; use warnings;

my $folder = "/home/mitochi/Desktop/Work/Codes/Perl/essential/";

my @files = <$folder/*>;
foreach my $file (@files) {
	my $cmd = "chmod 740 $file";
	system($cmd);
}


