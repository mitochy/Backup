#!/usr/bin/perl

use strict; use warnings; use mitochy;

my %orgid = %{mitochy::Global_Var("orgfullname")};
my %id;
# Process taxid
open (my $out, ">", "/data/mitochi/Work/Codes/Perl/db/orgtaxid.txt") or die "Cannot write to /data/mitochi/Work/Codes/Perl/db/orgtaxid.txt: $!\n";
open (my $taxid, "<", "/home/mitochi/Desktop/Work/Codes/Perl/db/TAXID") or die "Cannot read from TAXID: $!\n";
while (my $line = <$taxid>) {
	chomp($line);
	my ($id, $name) = split("\t", $line);
	$name =~ s/ /_/;
	$name = lc($name);
	#my ($name1, $name2) = split(" ", $name);
	#next if not defined($name2);
	#next if $name2 =~ /^sp\.$/;
	#$name1 =~ s/[\(\)'\[\]]//;
	#next if $name1 =~ /^\w\./;
	#($name1) = $name1 =~ /^(.+)$/;
	#die "$line\n" if not defined($name1);
	#$name = lc($name1 . $name2);
	#next if defined($id{$name}{id});
	$id{$name}{id} = $id;
}
close $taxid;

my $total = 0;
foreach my $family (keys %orgid) {
	foreach my $org (@{$orgid{$family}}) {
		$total++;
		$org = lc($org);
		my $id = $id{$org}{id};
		if (defined ($id{$org}{id})) {
			print $out "$id\n";
		}
		else {
			print "UNDEF $org\n";
		}
	}
}
print "Total organism = $total\n";
