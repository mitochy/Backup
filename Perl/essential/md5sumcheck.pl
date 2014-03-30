#!/usr/bin/perl

use strict; use warnings; use mitochy;

my ($folder1, $folder2) = @ARGV;
die "usage: $0 <folder1> <folder2>\n" unless @ARGV;

my %file;
my @files1 = <$folder1\/*.*>;
my @files2 = <$folder2\/*.*>;

foreach my $file (@files1) {
	my $md = md5sum($file);
	push(@{$file{$md}}, $file);
}
foreach my $file (@files2) {
	my $md = md5sum($file);
	push(@{$file{$md}}, $file);
}

foreach my $md (sort {scalar(@{$file{$b}}) <=> scalar(@{$file{$a}})} keys %file) {
	my $count = @{$file{$md}};
	next if $count == 1;
	print "MD $md has $count files: ";
	for (my $i = 0; $i < @{$file{$md}}; $i++) {
		print "$file{$md}[$i]";
		print "," if $i < @{$file{$md}} - 1;
		print "\n" if $i == @{$file{$md}} - 1;
	}
}

sub md5sum {
	my ($input) = @_;
	my $md5sum = `md5sum $input`;
	chomp($md5sum);
	return($md5sum);
}
