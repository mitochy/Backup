#!/usr/bin/perl

use strict; use warnings; use mitochy;

my ($input) = @ARGV;
die "usage: $0 input\n" unless @ARGV;
$input =~ s/\.\///ig;
die "Input should not have two slash/backslash\n" if $input =~ /\/.+\//;
my %orglist = %{mitochy::Global_Var('orglist')};
my $bigfamily;
foreach my $family (keys %orglist) {
	foreach my $org (@{$orglist{$family}}) {
		if ($input =~ /$org/) {
			$bigfamily = $family;
			print "Big family for $org ($input) already exists\n" and exit if $ARGV[0] =~ /$bigfamily/;
		}
	}
}
print "Organism family not found at $input\n" and exit unless defined($bigfamily);
print "org = $input, bigfamiy = $bigfamily\n";
#($input) = $input =~ /^\.{0,1}\/(.+)$/i;
my $cmd = "mv $input $bigfamily\.$input";
print "$cmd\n";
system($cmd);
