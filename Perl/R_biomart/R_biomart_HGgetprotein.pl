#!/usr/bin/perl

use strict; use warnings; use mitochy; use Cache::FileCache;

my $cache = new Cache::FileCache();
$cache -> set_cache_root("/home/mitochi/Desktop/Cache");
my $hggene = $cache -> get("hgiddb");
mitochy::process_hgskewIDdb() unless defined($hggene);
$hggene = $cache -> get("hgiddb") unless defined($hggene);
my %hggene = %{$hggene};

foreach my $hgid (keys %hggene) {
	foreach my $org (keys %{$hggene{$hgid}}) {
		my @id;
		foreach my $hgid (keys %hggene) {
			next if not defined($hggene{$hgid}{$org}{'id'});
			my $id = $hggene{$hgid}{$org}{'id'};
			push(@id, $id);
		}
		my $Rthis = mitochy::R_biomart_get($org, \@id, "peptide");
	}
	last;
}




