#!/usr/bin/perl

use strict; use warnings; use mitochy; use Cache::FileCache;

my %orglist = %{mitochy::Global_Var('orglist')};
my $cache = new Cache::FileCache();
$cache -> set_cache_root('/home/mitochi/Desktop/Cache');

my $orgid = $cache -> get("orgdb");
if (not defined($orgid)) {
	my %orgid = mitochy::process_orgID;
	$cache -> set("orgdb", \%orgid);
}
my %orgid = %{$orgid};
my @org = mitochy::return_org();
foreach my $org (@org) {
	my @id;
	foreach my $kogid(keys %orgid) {
		next if not defined($orgid{$kogid}{$org});
		my $id = $orgid{$kogid}{$org}{'id'};
		push(@id, $id);
	}
	my $Rthis = mitochy::R_biomart_get($org, \@id, '5utr');
}

