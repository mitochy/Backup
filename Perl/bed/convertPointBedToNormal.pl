#!/usr/bin/perl

use strict; use warnings; use mitochy;

my ($input) = @ARGV;
die "usage: $0 <input>\n" unless @ARGV;

my ($folder, $name) = mitochy::getFilename($input, "folder");

open (my $in, "<", $input) or die "Cannot read from $input: $!\n";
open (my $out, ">", "$name.out") or die "Cannot write to $name.out: $!\n";

while (my $line = <$in>) {
	chomp($line);
	print $out "$line\n" and next if $line =~ /#/;
	print $out "$line\n" and next if $line =~ /track/;
	my ($chr, $start, $end, $name, $val, $strand) = split("\t", $line);
	my ($context, $coverage, $meth) = split("_", $name);
	die "Died at line $line since not defined context or meth\n" unless defined($meth);
	print $out "$chr\t$start\t$end\t$name\t$meth\t$strand\n";
}

close $in;
close $out;


__END__
chr1	3010894	3010895	CHG_15_6.66666666666667	15	-	3010894	3010895	17,0,237
