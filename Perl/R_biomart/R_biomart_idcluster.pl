#!/usr/bin/perl

use strict; use warnings; use mitochy;

my @input = @ARGV;

die "usage: R_biomart_idcluster.pl <all .ID sequences\n" unless @ARGV;

my %kog;
my $linecount = 0;
my @org;
open (my $in0, "<", "/home/mitochi/Desktop/Work/newcegma/ID/core.id") or die "Cannot read from core.id: $!\n";
while (my $line0 = <$in0>) {
	chomp($line0);
	$linecount++;
	@org = split("\t", $line0) if $linecount == 1;
	next if $linecount == 1;
	
	my @arr = split("\t", $line0);
	my $kogid = $arr[0];
	for (my $i = 1; $i < @arr; $i++) {
		my $org = $org[$i];
		my $id  = uc($arr[$i]);
                ($id) = $id =~ /^(AT\w+)\.\d+$/i if $id =~ /^AT\w+\.\d+$/i;

		$kog{$kogid}{$org}{$id} = ();
	}
}
close $in0;

my %horg;
my %id;
foreach my $input (@input) {

	my ($org, $horg) = $input =~ /\/(\w+)\.id\.(\w+)\.ID\.new\.ID$/i;
	($org, $horg) = $input =~ /\/(\w+)\.id\.(\w+)\.ID$/i if not defined($org);
	die "input: $input\n" unless defined($org) and defined($horg);
	$horg{$org}{$horg}++;
	open (my $in, "<", $input) or die "Cannot read from $input: $!\n";
	while (my $line = <$in>) {
		chomp($line);
		next if $line =~ /"V1/i;
		next if $line =~ /Ensembl/;
		$line =~ s/"//ig;
	
		my @arr = split(" ", $line);
		my ($id, $hid) = (uc($arr[1]), uc($arr[2]));
		die "homolog org: $horg\n" unless defined($id) and defined($hid);
		$id{$org}{$horg}{$id} = $hid;
	}
}

foreach my $kogid (sort keys %kog) {
        print ">KOG\t";
        foreach my $org (sort keys %{$kog{$kogid}}) {
		print "$org\t";
                foreach my $id (sort keys %{$kog{$kogid}{$org}}) {
                        foreach my $horg (sort keys %{$id{$org}}) {
                                print "$horg\t";
                        }
                }
        }
        print "\n";
	last;
}

foreach my $kogid (sort keys %kog) {
	print "$kogid\t";
	foreach my $org (sort keys %{$kog{$kogid}}) {
		foreach my $id (sort keys %{$kog{$kogid}{$org}}) {
			print "$id\t";

			foreach my $horg (sort keys %{$id{$org}}) {
				print "$horg\_$id\_" if not defined($id{$org}{$horg}{$id});
				print "NA\t" if not defined($id{$org}{$horg}{$id});
				print "$id{$org}{$horg}{$id}\t" if defined($id{$org}{$horg}{$id});
			}
		}
	}
	print "\n";
} 

__END__

