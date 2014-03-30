#!/usr/bin/perl

use strict; use warnings; use mitochy; use Getopt::Std;
use vars qw($opt_c);
getopts("c:");

my (@input) = @ARGV;
die "usage: $0 -c column (default 0) <input>\n" unless @ARGV > 1;
my $column = defined($opt_c) ? $opt_c : 0;

my %data;
foreach my $input (@input) {
	%data = %{process_input($input, \%data)};
}


foreach my $data (sort keys %data) {
	my @files = sort @{$data{$data}};
	my $outName;
	for (my $i = 0; $i < @files; $i++) {
		my $name = mitochy::getFilename($files[$i]);
		$outName .= "$name";
		$outName .= $i == @files - 1 ? ".cons" : "\_";
	}
	open (my $out, ">", $outName) or die "Cannot write to $outName: $!\n";
	close $out;
}	

foreach my $data (sort keys %data) {
	my @files = sort @{$data{$data}};
	my $outName;
	for (my $i = 0; $i < @files; $i++) {
		my $name = mitochy::getFilename($files[$i]);
		$outName .= "$name";
		$outName .= $i == @files - 1 ? ".cons" : "\_";
	}
	open (my $out, ">>", $outName) or die "Cannot write to $outName: $!\n";
	print $out "$data\n";
	close $out;
}	


sub process_input {
	my ($input, $data) = @_;
	my $name = mitochy::getFilename($input);
	open (my $in, "<", $input) or die "Cannot read from $input: $!\n";
	my %data = %{$data};
	while (my $line = <$in>) {
		chomp($line);
		next if $line =~ /track/;
		next if $line =~ /\#/;
		my @arr = split("\t", $line);
		my $data = $arr[$column];
		push(@{$data{$data}}, $name);
	}
	close $in;
	return(\%data);
}
