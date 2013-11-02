#!/usr/bin/perl

use strict; use warnings;

my ($input) = @ARGV;
die "usage: $0 <organism name abbreviated (homo sapiens = hsapiens) space delimited>\n" unless @ARGV == 1;

my %id;
# Process taxid
open (my $in, "<", $input) or die "Cannot read from $input: $!\n";
open (my $out, ">", "$input\.id") or die "Cannot write to $input.id: $!\n";
open (my $taxid, "<", "/home/mitochi/Desktop/Work/Codes/Perl/db/TAXID") or die "Cannot read from TAXID: $!\n";
while (my $line = <$taxid>) {
	chomp($line);
	my ($id, $name) = split("\t", $line);
	my ($name1, $name2) = split(" ", $name);
	next if not defined($name2);
	next if $name2 =~ /^sp\.$/;
	$name1 =~ s/[\(\)'\[\]]//;
	next if $name1 =~ /^\w\./;
	($name1) = $name1 =~ /^(\w)/;
	die "$line\n" if not defined($name1);
	$name = lc($name1 . $name2);
	$id{$name}{id} = $id;
}
close $taxid;
my %org;
while (my $line = <$in>) {
	chomp($line);
	my ($name) = split("\t",$line);
	if (not defined($id{$name}{id})) {
		print "UNDEF $name\n";
	}
	else {
		print $out "$id{$name}{id}\n";
	}
}

