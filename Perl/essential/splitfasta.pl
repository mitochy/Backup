#!/usr/bin/perl

use strict; use warnings; use Getopt::Std;
use vars qw($opt_i $opt_l $opt_c);
getopts("i:l:c:");

die "
usage: $0 -i Fasta

Options:
-l: Output label in front of each chromosome [default: Nothing]
-c: chromosome to take (format: 1,2,3,4) [default: None]
    Make sure that chromosomes to take is exactly the same as fasta sequence name!
    E.g. if chromosome name is 1 and fasta header is >1_def:humangenome19 then this won't work!
    It might work if it's >1 def:humangenome19

" unless defined($opt_i);

my $input = $opt_i;
my $label = defined($opt_l) ? $opt_l : "";

my @chrom = split(",", $opt_c) if defined($opt_c);

my $currentChr = "INIT";
my %out;
open (my $in, "<", $input) or die "Cannot read from $input: $!\n";
while (my $line = <$in>) {
	chomp($line);
	
	next if $line =~ /\#/; # Next comments

	# If line is fasta header, then do below:
	if ($line =~ /^>/) {
		# If previous chromosome is requested, then print newline
		# close previous filehandle
		# and remove chromosome name from list
		if (grep(/^$currentChr$/, @chrom)) {
			print {$out{$currentChr}} "\n";
			close $out{$currentChr};

			# Remove chrom name from list
			# Exit if there is no more chromosome requested
			@chrom = grep {$_ ne $currentChr} @chrom;
			last if @chrom == 0;
		}

		# Get current chromosome
		($currentChr) = $line =~ />(.+)\s{0,1}.*$/;
		print "Processing line $line (current chromosome = $currentChr)\n";

		# If current chromosome is requested, then print out the fasta header
		if (grep(/^$currentChr$/, @chrom)) {
			my $output = $label . $currentChr . ".fa";
			print "Output = $output\n";
			open ($out{$currentChr}, ">", $output) or die "Cannot write to $output: $!\n";
			print {$out{$currentChr}} "$line\n";
		}
	}

	# If line is not a fasta header (sequence) then do below:
	else {
		# If current chromosome is requested, then print out the sequence
		if (grep(/^$currentChr$/, @chrom)) {
			print {$out{$currentChr}} "$line";
		}
	}

}
close $in;
