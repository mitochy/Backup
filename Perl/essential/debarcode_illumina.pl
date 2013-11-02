#!/usr/bin/perl

use strict; use warnings; use Getopt::Std;
use vars qw($opt_b);
getopts("b:");

my ($input) = @ARGV;
die "usage: $0 [-b barcode1] <illumina output>\n" unless @ARGV;
die "usage: $0 [-b barcode1] <illumina output>\nBarcode not defined\n" unless defined($opt_b);

my %output;
my $barcode = $opt_b;
print "Barcode: $barcode\n";
#my @barcode = split(",", $opt_b);
my %barcode;
#for (my $i = 0; $i < @barcode; $i++) {
open (my $out, ">", "$input\_$barcode.fastq") or die "Cannot write to $input\_$barcode.fastq: $!\n";
#	$barcode{$barcode[$i]} = 1;
#}

open (my $in, "<", $input) or die "Cannot read from $input: $!\n";
while (my $line = <$in>) {
	chomp($line);
	my $sequence;
	my $read;
	if ($line =~ /^\@HW/) {
		my $barcode2 = "";
		$sequence .= "$line\n";
		$line = <$in>;
		chomp($line);
		($barcode2, $read) = $line =~ /^(\w\w\w\w\w\w)(\w+)$/;
		die "Died: Fatal error undef barcode $barcode2 at line $line\n" if not defined($barcode2);
		$sequence .= "$read\n";
		$line = <$in>;
		chomp($line);
		$sequence .= "+\n";
		$line = <$in>;
		chomp($line);
		my ($barcode_qual, $qual) = $line =~ /^(......)(.+)$/;
		die "Died: Fatal error undef barcode $qual at line $line\n" if not defined($qual);
		$sequence .= "$qual\n";
		print $out "$sequence" if ($barcode eq $barcode2);
		
	}
	else {die "Died: Fatal error at line $line\n";}
}
close $in;
