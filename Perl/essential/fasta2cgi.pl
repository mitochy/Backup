#!/usr/bin/perl

use strict; use warnings; use mitochy; use FAlite;

my ($input) = @ARGV;

die "usage: $0 <fasta>\n" unless @ARGV;
my ($name) = mitochy::getFilename($input);

open (my $out_dens, ">", "$name\_dens.wig") or die "Cannot write to $name\_dens.wig: $!\n";
open (my $out_cont, ">", "$name\_cont.wig") or die "Cannot write to $name\_cont.wig: $!\n";
open (my $out_skew, ">", "$name\_skew.wig") or die "Cannot write to $name\_skew.wig: $!\n";
open (my $in, "<", $input) or die "Cannot read from $input: $!\n";
my $fasta = new FAlite($in);
while (my $entry = $fasta->nextEntry()) {
	my $chr = $entry->def;
	$chr =~ s/>//;
	my ($dens, $cont, $skew) = mitochy::dinuc_window_count($entry->seq,"C","G",200,10);
	my @dens = @{$dens};
	my @skew = @{$skew};
	my @cont = @{$cont};

	print $out_dens "variableStep chrom=$chr span=200\n";
	print $out_skew "variableStep chrom=$chr span=200\n";
	print $out_cont "variableStep chrom=$chr span=200\n";
	for (my $i = 0; $i < @dens; $i+=10) {
		print $out_dens "$i\t$dens[$i]\n";
		print $out_cont "$i\t$cont[$i]\n";
		print $out_skew "$i\t$skew[$i]\n";
	}
}
close $in;
