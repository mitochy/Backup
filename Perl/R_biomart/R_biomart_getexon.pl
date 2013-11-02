#!/usr/bin/perl
use strict; use warnings; 
use mitochy; use FAlite; use R_toolbox; use R_biomart;
use Cache::FileCache;

my %id = mitochy::process_kogIDdb();

my %seq;
foreach my $kogid (sort keys %id) {
	foreach my $org (sort keys %{$id{$kogid}}) {
		push(@{$seq{$org}}, $id{$kogid}{$org});
	}
}

my %newid;

# Build Exon Tables
if (check_exontables(%seq) == 9) {
	print "Running Necessary R scripts to download Exon tables...\n";
	exit;
}

# Read from Exon Tables
# And decide which transcript variant to use (currently using longest)
my @failures;
print "Reading exon tables...\n";
foreach my $org (sort keys %seq) {
	print "Reading $org.table.exon.txt...";
	open (my $in, "<", "/home/mitochi/Desktop/Work/newcegma/exon/$org.table.exon.txt") or die "Cannot read from /home/mitochi/Desktop/Work/newcegma/exon/$org.table.exon.txt: $!\n";
	while (my $line = <$in>) {

		chomp($line);
		$line =~ s/"//ig;
		next if $line !~ /^\d+/;
		
		my ($num, $id, $transc, $start, $end, $strand, $chr) = split(" ", $line);
		$id = uc($id);
		push(@{$newid{'temp'}{$org}{$id}{'test'}{$transc}}, [$start, $end, $strand, $chr]);
		#print "$org $id $transc\n";
	}
	close $in;
	print "Done\n";
	foreach my $id (sort keys %{$newid{'temp'}{$org}}) {
		my $longest = 0;
		my $longestid;
		
		#use transcript with longest seq end-start (not sequence length)
		foreach my $transc (sort keys %{$newid{'temp'}{$org}{$id}{'test'}}) {
			my $length = 0;
			my $end_num = @{$newid{'temp'}{$org}{$id}{'test'}{$transc}}-1;

			my ($start, $end) = $newid{'temp'}{$org}{$id}{'test'}{$transc}[0][2] == 1 ? ($newid{'temp'}{$org}{$id}{'test'}{$transc}[0][0], $newid{'temp'}{$org}{$id}{'test'}{$transc}[$end_num][1]) : ($newid{'temp'}{$org}{$id}{'test'}{$transc}[$end_num][1], $newid{'temp'}{$org}{$id}{'test'}{$transc}[0][0]);
			$length = abs($end - $start);
			$longestid = $transc if $longest < $length;
			$longest = $length if $longest < $length;
		}
		$newid{'temp'}{$org}{$id}{'longest'} = $newid{'temp'}{$org}{$id}{'test'}{$longestid};
		$newid{'temp'}{$org}{$id}{'longestid'} = $longestid;
	}
}

# Put data of exons into Hash
print "Putting exon data on hash...\n";
my %cache;
foreach my $kogid (sort keys %id) {
        foreach my $org (sort keys %{$id{$kogid}}) {
		my $id = $id{$kogid}{$org};
		next if $id =~ /NA/ or not defined($newid{'temp'}{$org}{$id}{'longest'});
		
		for (my $i = 0; $i < @{$newid{'temp'}{$org}{$id}{'longest'}}; $i++) {	
			my $num = $i+1;
			my $start 	= $newid{'temp'}{$org}{$id}{'longest'}[$i][0];
			my $end 	= $newid{'temp'}{$org}{$id}{'longest'}[$i][1];
			my $strand 	= $newid{'temp'}{$org}{$id}{'longest'}[$i][2];
			my $chr 	= $newid{'temp'}{$org}{$id}{'longest'}[$i][3];
			my $longestid	= $newid{'temp'}{$org}{$id}{'longestid'};
			$cache{$kogid}{$org}{$id}{'exon'}[$i]{'start'} = $start;
			$cache{$kogid}{$org}{$id}{'exon'}[$i]{'end'} = $end;
			$cache{$kogid}{$org}{$id}{'exon'}[$i]{'strand'} = $strand;
			$cache{$kogid}{$org}{$id}{'exon'}[$i]{'chr'} = $chr;
			$cache{$kogid}{$org}{$id}{'exon'}[$i]{'id'} = $longestid;
		}
	}
}

my $cache = new Cache::FileCache();
$cache -> set_cache_root("/home/mitochi/Desktop/Cache");
$cache -> set("exondb", \%cache);
print "Cache set for exontables using key exondb\n";
#Check if exon table files exists or not. If not, retrieve exon data from R_biomart.
sub check_exontables {
	my (%seq) = @_;
	my @R_biomart_Exon;
	my @Failed_R_biomart_Exon;
	print "Checking Exon Tables for each organisms...\n";
	foreach my $org (sort keys %seq) {
		if (not -e "/home/mitochi/Desktop/Work/newcegma/exon/$org.table.exon.txt") {
			print "Table $org not exists, creating...\n";
			my $temp_id = R_toolbox::newRArray(\@{$seq{$org}}, "$org.id", "with_quote");
			my $R_biomart = "library(biomaRt)\n";
			$R_biomart .= R_biomart::getexon($org, $temp_id);
			open (my $out, ">", "/home/mitochi/Desktop/Work/newcegma/exon/$org.table.exon.R") or die "Cannot write 
to $org.table.exon.R: $!\n";
			print $out "$R_biomart";
			close $out;
			push (@R_biomart_Exon, "/home/mitochi/Desktop/Work/newcegma/exon/$org.table.exon.R");
		}
		else {
			print "Table $org size is 0, redownloading...\n";
			my $size = -s "/home/mitochi/Desktop/Work/newcegma/exon/$org.table.exon.txt";
			if ($size == 0) {
				my $temp_id = R_toolbox::newRArray(\@{$seq{$org}}, "$org.id", "with_quote");
				my $R_biomart = "library(biomaRt)\n";
				$R_biomart .= R_biomart::getexon($org, $temp_id);
				open (my $out, ">", "/home/mitochi/Desktop/Work/newcegma/exon/$org.table.exon.R") or die "Cannot write to $org.table.exon.R: $!\n";
				print $out "$R_biomart";
				close $out;
				push (@R_biomart_Exon, "/home/mitochi/Desktop/Work/newcegma/exon/$org.table.exon.R");
			}
		}
	}

	print "Running R_toolbox.pm:execute_Rscript\n";
	R_toolbox::execute_Rscript(\@R_biomart_Exon, "multi") if @R_biomart_Exon > 0;
	return(9) if @R_biomart_Exon > 0;
}
