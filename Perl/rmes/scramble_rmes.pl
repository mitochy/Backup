#!/usr/bin/perl

use strict; use warnings; use mitochy;

my @input = @ARGV;

die "usage: scramble.pl rmesinput1 rmesinput2\n" unless @ARGV;

foreach my $input (@input) {
	print "processing $input\n";
	for (my $i = 0; $i < 10; $i++) {
		print "\tprocessing $input : $i\n";
	
		open (my $in, "<", $input) or die "Cannot read from $input: $!\n";
		open (my $out, ">", "$input.$i.rmesinput") or die "Cannot write to $input.$i.rmesinput: $!\n";
		print $out ">$input\n";	
	
		while (my $line = <$in>) {
			next if $line =~ /^>/i;
			my @arr = split("Z",$line);
			foreach my $arr (@arr) {
				my $newseq = mitochy::scramble($arr);
				print $out "$newseq";
				print $out "Z";
			}
		} 
		
		close $in;
		close $out;
	}
	print "done\n";
}