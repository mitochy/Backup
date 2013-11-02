#!/usr/bin/perl

use strict; use warnings; use mitochy; use FAlite; use R_toolbox; use R_biomart;
use Cache::FileCache;

die "usage: $0 <flank>\n" unless @ARGV;
my $flank = $ARGV[0];

my $cache = new Cache::FileCache();
$cache -> set_cache_root("/home/mitochi/Desktop/Cache");
my $flankcache = $cache -> get("orgdbflank_$flank");
my %id = mitochy::process_kogIDdb();

print "Processing flank database for flank = $flank...\n";
#if (not defined($flankcache)) {
	print "DB not exists, creating...\n";
	mitochy::process_biomart_flank($flank);
	$flankcache = $cache -> get("orgdbflank_$flank");
#}

print "Done\n";
my %org = %{$flankcache};

mkdir "/home/mitochi/Desktop/Work/newcegma/flankgene/$flank" if (not -d "/home/mitochi/Desktop/Work/newcegma/flankgene/$flank");
print "Separating flank IDs based on database\n";
foreach my $null (sort keys %org) {
	foreach my $org (sort keys %{$org{$null}}) {
		open (my $out, ">", "/home/mitochi/Desktop/Work/newcegma/cpglite/flankgene/$flank/$org.$flank.no_flank.txt") or die "Cannot open output no flank: $!\n";
		open (my $out2, ">", "/home/mitochi/Desktop/Work/newcegma/cpglite/flankgene/$flank/$org.$flank.flank_start_plus.txt") or die "Cannot open output no flank: $!\n";
		open (my $out3, ">", "/home/mitochi/Desktop/Work/newcegma/cpglite/flankgene/$flank/$org.$flank.flank_start_minus.txt") or die "Cannot open output no flank: $!\n";
		open (my $out4, ">", "/home/mitochi/Desktop/Work/newcegma/cpglite/flankgene/$flank/$org.$flank.flank_end_plus.txt") or die "Cannot open output no flank: $!\n";
		open (my $out5, ">", "/home/mitochi/Desktop/Work/newcegma/cpglite/flankgene/$flank/$org.$flank.flank_end_minus.txt") or die "Cannot open output no flank: $!\n";
		open (my $out6, ">", "/home/mitochi/Desktop/Work/newcegma/cpglite/flankgene/$flank/$org.$flank.flank_both_plusplus.txt") or die "Cannot open output no flank: $!\n";
		open (my $out7, ">", "/home/mitochi/Desktop/Work/newcegma/cpglite/flankgene/$flank/$org.$flank.flank_both_plusminus.txt") or die "Cannot open output no flank: $!\n";
		open (my $out8, ">", "/home/mitochi/Desktop/Work/newcegma/cpglite/flankgene/$flank/$org.$flank.flank_both_minusplus.txt") or die "Cannot open output no flank: $!\n";
		open (my $out9, ">", "/home/mitochi/Desktop/Work/newcegma/cpglite/flankgene/$flank/$org.$flank.flank_both_minusminus.txt") or die "Cannot open output no flank: $!\n";
		#print "$org\n";
		foreach my $kogid (sort keys %org) {
			my $id = $id{$kogid}{$org};
		
			# Both Flanks
			if (defined($org{$kogid}{$org}{'flank_start'}[0][0]) and defined($org{$kogid}{$org}{'flank_end'}[0][0])) {
				die if $org{$kogid}{$org}{'flank_start'}[0][0] =~ /^$id$/i;
				if ($org{$kogid}{$org}{'flank_start'}[0][1] == 1 and $org{$kogid}{$org}{'flank_end'}[0][1] == 1) {
					print $out6 "$kogid\t$id\t+/+\n";
				}
				if ($org{$kogid}{$org}{'flank_start'}[0][1] == 1 and $org{$kogid}{$org}{'flank_end'}[0][1] == -1) {
					print $out7 "$kogid\t$id\t+/-\n";
				}
				if ($org{$kogid}{$org}{'flank_start'}[0][1] == -1 and $org{$kogid}{$org}{'flank_end'}[0][1] == 1) {
					print $out8 "$kogid\t$id\t-/+\n";
				}
				if ($org{$kogid}{$org}{'flank_start'}[0][1] == -1 and $org{$kogid}{$org}{'flank_end'}[0][1] == -1) {
					print $out9 "$kogid\t$id\t-/-\n";
				}
				next;
			}
			elsif (defined($org{$kogid}{$org}{'flank_start'}[0][0])) {
				if ($org{$kogid}{$org}{'flank_start'}[0][1] == 1) {
					print $out2 "$kogid\t$id\tstart +\n";
				}
				if ($org{$kogid}{$org}{'flank_start'}[0][1] == -1) {
					print $out3 "$kogid\t$id\tstart -\n";
				}
			}
			elsif (defined($org{$kogid}{$org}{'flank_end'}[0][0])) {
				if ($org{$kogid}{$org}{'flank_end'}[0][1] == 1) {
					print $out4 "$kogid\t$id\tend +\n";
				}
				if ($org{$kogid}{$org}{'flank_end'}[0][1] == -1) {
					print $out5 "$kogid\t$id\tend -\n";
				}
			}
			else {
				print $out "$kogid\t$id\tno_flank\n";
			}
		}
	}
	exit;
}
		
		
