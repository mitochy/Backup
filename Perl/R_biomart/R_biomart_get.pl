#!/usr/bin/perl
use strict; use warnings; use mitochy; use FAlite;

die "usage: R_biomart_get.pl <query> <run = 1, force redownload table = 2, not run = anything> <flank> \n" unless @ARGV >=2;
my ($query, $run, $flank) = @ARGV;
my %id = mitochy::process_kogIDdb();

#my @retrieve;
#foreach my $kogid (sort keys %id) {
#	push(@retrieve, $kogid);
#}

#my @retrieve = qw(
#KOG1885
#);

foreach my $kogid (sort keys %id) {
        foreach my $org (sort keys %{$id{$kogid}}) {
               # open (my $out, ">", "core.$org.$query") or die;
	#	close $out;
        }
	last;
}

my %seq;
foreach my $kogid (sort keys %id) {
	foreach my $org (sort keys %{$id{$kogid}}) {
		push(@{$seq{$org}}, $id{$kogid}{$org});
	}
}

#Get all table set up
my %newid;
my @failures;
my @Rthis;
my $newflank;
foreach my $org (sort keys %seq) {
	$newflank = $flank if defined($flank);
	$newflank = 0 if not defined($flank);
	my $Rthis = mitochy::R_biomart_get($org, \@{$seq{$org}}, $query, $flank) if $run == 2 or $run == 3 or not (-e ".\/$org.table.$query.$newflank\_flank.txt");
	push(@Rthis, $Rthis) if $run == 2 or $run == 3 or not (-e ".\/$org.table.$query.$newflank\_flank.txt");
}

#Run R
my $cmd;
foreach my $Rthis (@Rthis) {
	$cmd .= "sudo nice -n -20 $Rthis & ";
}
print "$cmd\n";
system($cmd) if $run == 1 or $run == 3;

#foreach my $org (sort keys %seq) {
#	my $size = -s ".\/$org.table.$query.txt";
#	push (@failures, "$org.table.$query.txt") if $size == 0;
#	next if $size == 0;
#}
exit;

#Main
#To get all sequence an dprint it to core.id
foreach my $org (sort keys %seq) {
	open (my $in, "<", ".\/$org.table.$query.$newflank\_flank.txt") or next;#die "Cannot read from ./$org.table.txt: $!\n";
	while (my $line = <$in>) {
		chomp($line);
		$line =~ s/"//ig;
		next if $line !~ /^\d+/;
		
		my ($num, $id, $transc, $start, $end, $strand, $chr) = split(" ", $line);
		$id = uc($id);
		push(@{$newid{$org}{$id}{'test'}{$transc}}, [$start, $end, $strand, $chr]);
		#print "$org $id $transc\n";
	}
	close $in;
	foreach my $id (sort keys %{$newid{$org}}) {
		my $longest = 0;
		my $longestid;
		
		#use transcript with longest seq
		foreach my $transc (sort keys %{$newid{$org}{$id}{'test'}}) {
			my $length = 0;
			my $end_num = @{$newid{$org}{$id}{'test'}{$transc}}-1;

			my ($start, $end) = $newid{$org}{$id}{'test'}{$transc}[0][2] == 1 ? ($newid{$org}{$id}{'test'}{$transc}[0][0], $newid{$org}{$id}{'test'}{$transc}[$end_num][1]) : ($newid{$org}{$id}{'test'}{$transc}[$end_num][1], $newid{$org}{$id}{'test'}{$transc}[0][0]);
			$length = abs($end - $start);
			#for (my $i = 0; $i < @{$newid{$org}{$id}{'test'}{$transc}}; $i++) {
			#	my ($start, $end) = ($newid{$org}{$id}{'test'}{$transc}[$i][0], $newid{$org}{$id}{'test'}{$transc}[$i][1]);
			#	$length += $end-$start;
			#}
			print "$transc\n" if $org =~ /dyakuba/i;
			$longestid = $transc if $longest < $length;
			$longest = $length if $longest < $length;
		}
		$newid{$org}{$id}{'longest'} = $newid{$org}{$id}{'test'}{$longestid};
	}
}


foreach my $kogid (sort keys %id) {
#        next if not grep(/^$kogid$/, @retrieve);
        foreach my $org (sort keys %{$id{$kogid}}) {
		open (my $out, ">>", "core.$org.$query") or die "Cannot write to core.$org.$query.txt: $!\n";
		
		my $id = $id{$kogid}{$org};
		#print "\"NA\" " if $id =~ /NA/ or not defined($newid{$org}{$id}{'longest'});
		next if $id =~ /NA/ or not defined($newid{$org}{$id}{'longest'});
		
		for (my $i = 0; $i < @{$newid{$org}{$id}{'longest'}}; $i++) {	
			my $num = $i+1;
			my $start 	= $newid{$org}{$id}{'longest'}[$i][0];
			my $end 	= $newid{$org}{$id}{'longest'}[$i][1];
			my $strand 	= $newid{$org}{$id}{'longest'}[$i][2];
			my $chr 	= $newid{$org}{$id}{'longest'}[$i][3];
			print $out "\"$num\" \"$kogid\_$id\_$num\" \"$kogid\_$id\_$num\" \"$chr\" $start $end $strand\n";
		}
	}
}

foreach my $fail (@failures) {
	print "Failed due to 0 size: $fail\n";
}
