#!/usr/bin/perl

use strict; use warnings; use mitochy;

my ($file, $del, $rename) = @ARGV;
die "usage: $0 <file> <rename what from name> <rename to>\n" unless @ARGV >= 2;

my ($keep1, $keep2) = $file =~ /^(.*)$del(.*)$/;
#print "$file\n$keep1\n$keep2\n";

print "$del does not exists in the file name\n" and exit unless defined($keep1) or defined($keep2);
$rename = "" if not defined($rename);
print "new file name: $keep1$rename$keep2\n";
my $file2 = $keep1 . $rename . $keep2;

my $cmd = "mv $file $file2";
print "$cmd\n";

system($cmd) == 0 or die "renaming file failed: $!\n";
