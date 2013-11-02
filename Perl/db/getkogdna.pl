#!/usr/bin/perl

use strict; use warnings; use mitochy; use FAlite;
use Cache::FileCache;

my %id = mitochy::process_kogIDdb();
my %kogid;
foreach my $kogid (sort keys %id) {
	foreach my $org (sort keys %{$id{$kogid}}) {
		my $id = $id{$kogid}{$org};
		die if not defined($id);
		$kogid{$kogid}{$id}{$org}{'id'}++;
#		print "$id\n";
	}
}	
#die;
my $cache = new Cache::FileCache();
$cache -> set_cache_root("/home/mitochi/Desktop/Cache");
my $dna_db = $cache -> get ("dnadb_min1000");
#if (not defined($dna_db)) {
	#print "not defined dnabd\n";
	my $folder = "/home/mitochi/Desktop/Work/newcegma/kmer/min1000";
	my @fasta = <$folder/*.fa>;
	foreach my $fasta (@fasta) {
		my ($org) = $fasta =~ /(\w+).fa$/i;
		my %fasta = mitochy::process_fasta($fasta);
		foreach my $head (sort keys %fasta) {
			my ($id) = $head =~ /^>(.+)_strand/i;
			die if not defined($id);
			#print "$id\n";
			#next if not defined($kogid{$kogid}{$org}{'id'});
			foreach my $kogid (sort keys %kogid) {
				next if not defined($kogid{$kogid}{$id});
				#print "avc $id\n";
				$kogid{$kogid}{$id}{$org}{'seq'} = $fasta{$head}{'seq'};
			}
		}
	}
	#$cache -> set("dnadb_min1000", \%kogid);
#}

#my $kogidtmp = $cache -> get("dnadb_min1000");
#%kogid = %{$kogidtmp};
print "Processing sequence files done\n";
foreach my $kogid (sort keys %kogid) {
	open (my $out, ">", "/home/mitochi/Desktop/Work/newcegma/kmer/min1000/kogseq/$kogid.fa") or die "Cannot write to output: $!\n";
	foreach my $id (sort keys %{$kogid{$kogid}}) {
		#print "here\n";
		foreach my $org (sort keys %{$kogid{$kogid}{$id}}) {
			#print "$org\n";
			next if not defined($kogid{$kogid}{$id}{$org}{'seq'});
			#print "$id\n";
			print $out ">$org\_$kogid\_$id\n$kogid{$kogid}{$id}{$org}{'seq'}\n";
		}
	}
	close $out;
}

