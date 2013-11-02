#!/usr/bin/perl

use strict; use warnings;

my ($ftplist) = @ARGV;

die "Usage: dbdownload_fasta.pl ftplist\n" unless @ARGV;

my $folder = "/home/mitochi/Desktop/Work/newcegma/database";

open (my $in, "<", $ftplist) or die "Cannot read from $ftplist: $!\n";

while (my $line = <$in>) {
	chomp($line);
	if ($line !~ /.gz$/i) {
		#print "line is not .gz!\n";
		print "skipped line is not .gz: $line\n";
		next;
	}
	my ($org, $fh) = $line =~ /gtf\/(\w+_\w+)\/(.*.gz)/i;
	my $dir = "$folder\/gtf/$org"; 
	my ($fasta) = $fh =~ /^(.+).gz$/i;
	print "dir = $dir\n";
	unless (-d $dir) {
		mkdir $dir or print "Failed to creat directory $dir: $!\n";
	}

	chdir $dir;
	my $cmd = "curl $line > $dir\/$fh";
	print "\tcmd = $cmd\n";
	system($cmd);
	my $cmd2 = "gunzip $dir\/$fh";
	print "\tcmd2 = $cmd\n";
	system($cmd2);
	chdir $folder;
}

close $in;
