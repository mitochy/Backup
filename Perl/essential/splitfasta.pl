#!/usr/bin/perl

use strict; use warnings; use FAlite;

die "usage: $0 <fasta> <label in front>\n" unless @ARGV == 1;
my ($input, $label) = @ARGV;
$label = "" if not defined($label);

open (my $in, "<", $input) or die "Cannot read from $input: $!\n";
my $fasta = new FAlite($in);
while (my $entry = $fasta->nextEntry()) {
	my ($defs, $seq) = ($entry->def, $entry->seq);
	#my ($def) = $defs =~ /^>(.{10})/;
	#($def) = $defs =~ /^>(.{5})/ if not defined($def);
	#($def) = $defs =~ /^>(.{1,5})/ if not defined($def);
	$defs =~ s/ /_/ig;
	$defs =~ s/>//ig;
	open (my $out, ">", "$input\_$defs\.fa") or die "Cannot write to $defs: $!\n";
	print $out ">$defs\n$seq";
	close $out;
	print "$input\_$defs\.fa";
}
close $in;
