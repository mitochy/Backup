#!/usr/bin/perl

use strict; use warnings;

my ($input) = @ARGV;
die "usage: $0 <input [chordate | metazoa | fungi | plants | protists | bacteria]>\n" unless @ARGV == 1;
my $metazoa = "ftp://ftp.ensemblgenomes.org/pub/metazoa/current/fasta/";
my $fungi = "ftp://ftp.ensemblgenomes.org/pub/fungi/current/fasta/";
my $bacteria = "ftp://ftp.ensemblgenomes.org/pub/bacteria/current/fasta/";
my $protists = "ftp://ftp.ensemblgenomes.org/pub/protists/current/fasta/";
my $chordates = "ftp://ftp.ensembl.org/pub/current_fasta/";
my $plants = "ftp://ftp.ensemblgenomes.org/pub/plants/current/fasta/";

my @list;
@list = ($chordates) if $input eq "chordates";
@list = ($plants) if $input eq "plants";
@list = ($fungi) if $input eq "fungi";
@list = ($metazoa) if $input eq "metazoa";
@list = ($protists) if $input eq "protists";
@list = ($bacteria) if $input eq "bacteria";
die "usage: $0 <input [chordate | metazoa | fungi | plants | protists | bacteria]>\n" if @list == 0;

open (my $out, ">>", "./dblist.txt") or die "Cannot write to output: $!\n";

foreach my $list (@list) {
	my $cmd = "curl $list";
	print "cmd = $cmd\n";
	my @cmd = `$cmd`;
	for (my $i = 0; $i < @cmd; $i++) {
		chomp($cmd);
		print "$cmd[$i]\n";
		my ($org) = $cmd[$i] =~ / (\w+_\w+)$/i;
		next if not defined($org);
		my $orglist = $list . "$org\/dna\/";
		print "list = $orglist\n";
		my @newlist = `curl $orglist`;
		
		my $newcmd;
		foreach my $newlist (@newlist) {
			($newcmd) = $newlist =~ / (\w+_\w+.+.dna.toplevel.fa.gz)$/i if $newlist =~ /.dna.toplevel.fa.gz/i;
			
		}
		print $out "$orglist\/$newcmd\n";		
	}
}
close $out;
