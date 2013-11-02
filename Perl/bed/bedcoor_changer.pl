#!/usr/bin/perl

use strict; use warnings;

BEGIN {
	my $lib = "$ENV{'HOME'}\/Desktop\/Work\/Codes\/Perl\/lib";
	push(@INC, $lib);
}

use mitochy; use Getopt::Std;
use vars qw($opt_s $opt_e $opt_o);
getopts("s:e:o");

my (@input) = @ARGV;

die "usage: script.pl bed1 bed2 bed3\ndefault start = -1000 and default end = -1000\n\n" unless @ARGV;

$opt_s = 1000 if not defined($opt_s);
$opt_e = 1000 if not defined($opt_e);

foreach my $input (@input) {
	my $printout;
	my ($name )= $input =~ m/.+\/(.+)\.\w\w\w{0,1}$/i;
	$name = $input if not defined($name);
	print "processing $input\n";
	my %bed = mitochy::process_bed($input);
	my $length = 0;

	foreach my $chr (sort keys %bed) {
		foreach my $genenum (sort keys %{$bed{$chr}}) {
			$bed{$chr}{$genenum}{'start'} += $opt_s;
			$bed{$chr}{$genenum}{'end'} -= $opt_e;
			$length = abs($bed{$chr}{$genenum}{'start'} - $bed{$chr}{$genenum}{'end'});
			if ($opt_o) {
				
				$printout .= "$chr $bed{$chr}{$genenum}{'start'}\t$bed{$chr}{$genenum}{'end'}\n";
			}
			else {
				print "$chr $bed{$chr}{$genenum}{'start'}\t";
				print "$bed{$chr}{$genenum}{'end'}\n";
			}
		}
	}
	
	if ($opt_o) {
		open (my $out, ">", "$input.$length\_bp.bed") or die "Cannot write to $input.$length\_bp.bed: $!\n";
		print $out "track name=\"$name\_$length\"\n";
		print $out "$printout";
		close $out;
	}



	print "output is: $input.$length\_bp.bed\n" if ($opt_o);
	
	
}

__END__
chrX 16877978	16897978
chrX 34665405	34685405
chrX 48804893	48824893
chrX 51802279	51822279
chrX 51802368	51822368
chrX 72289351	72309351
chrX 148611312	148631312
chrX 153765233	153785233
chrY 21144705	21164705
