#!/usr/bin/perl

use strict; use warnings;

my ($ext1, $ext2, $folder) = @ARGV;
die "usage: $0 ext1 (subject) ext2 (query)\n" unless @ARGV;
my @files1 = <./*$ext1>;
my @files2 = <./*$ext2>;
print "Warning: File with $ext1 not found\n" unless @files1 > 0;
print "Warning: File with $ext2 not found\n" unless @files2 > 0;

my $Rthis;
foreach my $files (@files1) {
	#print "processing $files\n";
	my ($filestemp) = $files =~ /(.+)$ext1/;
	die "filestemp at file $files undefined\n" unless defined($filestemp);
	$filestemp .= "$ext2";
	print "File $filestemp not found at $ext2\n" unless grep(/$filestemp/, @files2);
	$Rthis .= "R --vanilla --no-save < $files & " unless grep(/$filestemp/, @files2);
}
print "$Rthis\n";
system($Rthis)
