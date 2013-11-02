#!/usr/bin/perl
# Script to download Flank Genes using R_biomart


use strict; use warnings;
use mitochy;
use FAlite;
use Cache::FileCache;
use R_toolbox;
use R_biomart;

my ($flank) = @ARGV;
die "usage: $0 <flank>\n" unless defined($flank);
my %id = mitochy::process_kogIDdb();

my $orgcache = new Cache::FileCache();
my $org_cache = $orgcache -> get("orgdb");
if (not defined($org_cache)) {
	print "NOT DEFINED\n";
	my %orgs = mitochy::process_orgID();
	my $orgscalar = \%orgs;	
	$orgcache -> set ("orgdb", $orgscalar);
}

my %org = %{$org_cache};
my @kog;
foreach my $kog (sort keys %org) {
	my $count = 0;
	foreach my $org (sort keys %{$org{$kog}}) {
		$count++;
	}
	push(@kog, [$count, $kog]) if $count >= 0;
} 

my %orgtemp;
foreach my $kog (sort {$b -> [0] <=> $a -> [0]} @kog) {
	my $kogid = $kog->[1];
	my $numbr = $kog->[2];
	foreach my $org (sort keys %{$org{$kogid}}) {
		my $id = $org{$kogid}{$org}{'id'};
		#print "$id\n" if defined($id);
		next if not defined($id);
		$orgtemp{$org}{$id}{'chr'} = $org{$kogid}{$org}{'chr'};
                $orgtemp{$org}{$id}{'start'} = $org{$kogid}{$org}{'start'};
                $orgtemp{$org}{$id}{'end'} = $org{$kogid}{$org}{'end'};
                $orgtemp{$org}{$id}{'strand'} = $org{$kogid}{$org}{'strand'};
	}	
}

my @failures;
my $Rthis;
foreach my $org (sort keys %orgtemp) {
	my @chr;
	my @start;
	my @end;

	my $R_biomart = "library(biomaRt)\n";
	my ($R_biomart2, $buff1, $buff2) .= R_biomart::getdataset($org);
	$R_biomart .= $R_biomart2;
	foreach my $id (sort keys %{$orgtemp{$org}}) {
		my $chr = $orgtemp{$org}{$id}{'chr'};
                my $start = $orgtemp{$org}{$id}{'start'};
                my $end = $orgtemp{$org}{$id}{'end'};
                my $strand = $orgtemp{$org}{$id}{'strand'};
		push(@chr, $chr);
		push(@start, $start-$flank);
		push(@end, $end+$flank);
	}
	my $chr = R_toolbox::newRArray(\@chr, "$org.chr", "with_quote");
	my $start = R_toolbox::newRArray(\@start, "$org.start", "with_quote");
	my $end = R_toolbox::newRArray(\@end, "$org.end", "with_quote");

	$R_biomart .= R_biomart::getflankgenes($org, $chr, $start, $end, $flank);

	open (my $out, ">", "$org.flankgenes.$flank.R") or die "Cannot write to $org.flankgenes.$flank.R: $!\n";
	print $out "$R_biomart";
	close $out;

	$Rthis .= "R --vanilla --no-save < $org.flankgenes.$flank.R &";
}

system($Rthis);

__END__
