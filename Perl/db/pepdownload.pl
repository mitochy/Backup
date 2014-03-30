#!/usr/bin/perl

use strict; use warnings;

my ($input) = @ARGV;

die "usage: $0 <input [chordate | metazoa | fungi | plants | protists | bacteria]>\n" unless @ARGV == 1;

my $metazoa = "ftp://ftp.ensemblgenomes.org/pub/metazoa/current/gtf/";
my $fungi = "ftp://ftp.ensemblgenomes.org/pub/fungi/current/gtf/";
my $bacteria = "ftp://ftp.ensemblgenomes.org/pub/bacteria/current/gtf/";
my $protists = "ftp://ftp.ensemblgenomes.org/pub/protists/current/gtf/";
my $chordates = "ftp://ftp.ensembl.org/pub/current_gtf/gtf/";
my $plants = "ftp://ftp.ensemblgenomes.org/pub/plants/current/gtf/";

my @list;
@list = ($chordates) if $input eq "chordates";
@list = ($plants) if $input eq "plants";
@list = ($fungi) if $input eq "fungi";
@list = ($metazoa) if $input eq "metazoa";
@list = ($protists) if $input eq "protists";
@list = ($bacteria) if $input eq "bacteria";
die "usage: $0 <input [chordate | metazoa | fungi | plants | protists | bacteria]>\n" if @list == 0;

open (my $out, ">>", "./gtflist.txt") or die "Cannot write to ./gtflist: $!\n";

foreach my $list (@list) {
	my $cmd = "curl $list";
	print "cmd = $cmd\n";
	my @cmd = `$cmd`;
	for (my $i = 0; $i < @cmd; $i++) {
		chomp($cmd);
		print "$cmd[$i]\n";
		my ($org) = $cmd[$i] =~ / (\w+_\w+)$/i;
		print "Failed to get $cmd[$i]\n" and next if not defined($org);
		my $secondlist = $list . "$org\/";
		print "$list\n";
		my @newlist = `curl $secondlist`;
		print "NEW LIST:\n";
		print "@newlist\n";
		my $newcmd;
		foreach my $newlist (@newlist) {
			($newcmd) = $newlist =~ / (\w+_\w+.+\.gtf\.gz)$/i if $newlist =~ /\.gtf\.gz/i;
		}
		print $out "$secondlist\/$newcmd\n";
		print "$secondlist\/$newcmd\n";
	}
}
close $out;
