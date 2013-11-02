#!/usr/bin/perl

use strict; use warnings;

my ($folder, $input_name) = @ARGV;
die "usage: $0 <folder> <name (e.g. E14)>\n" unless @ARGV == 2;

my @samfile = <$folder/*.sam>;
my @group;
my $count_unique_id = 0;
my $total_id = 0;
foreach my $samfile (@samfile) {
	my ($name) = $samfile =~ /(\w+)\_trimmed/;
	push(@group, $name) if not grep(/^$name$/, @group);
}

foreach my $name (@group) {
	next if $name ne $input_name;
	print "Processing $name\n";
	my @file = <$folder/$name\_trimmed*.sam>;
	print "\tGoing to process files: @file\n";
}

foreach my $name (@group) {
	next if $name ne $input_name;
	#open (my $out, ">", "$name\_combined\_reads.fq") or die "Cannot write to $name\_combined\_reads.fq: $!\n";
	my %read;
	my @file = <$folder/$name\_trimmed*.sam>;
	my %id;
	my @prog;
	foreach my $file (@file) {
		print "Processing file $file\n";
		my ($prog) = $file =~ /trimmed\_(\w+)\.sam/;
		push(@prog, $prog);
		open (my $in, "<", $file) or die "Cannot read from $file: $!\n";
		while (my $line = <$in>) {
			chomp($line);
			#print $out "$line\n" if $line =~ /^@/;
			next if $line =~ /^@/;
			my ($names, $flag, $chr, $start, $junk, $mapq, $junk2, $junk3, $junk4, $seq, $bqual, $tag) = split("\t", $line);
	
			my ($id1, $id2, $id3) = $names =~ /d1gedacxx\:8\:(\d+)\:(\d+)\:(\d+)/;
			my $id = "$id1\_$id2\_$id3";
			my $strand = $flag == 0 ? "+" : "-";
			$read{$id}{$prog}{chr}    = $chr;
			$read{$id}{$prog}{start}  = $start;
			$read{$id}{$prog}{mapq}   = $mapq;
			$read{$id}{$prog}{strand} = $strand;
			#$read{$id}{$prog}{line}   = $line;
			$id{$id} = 1;
			#print "prog = $prog\nid = $id\nchr = $chr\nstart = $start\nmapq = $mapq\nstrand = $strand\n";
			#last;
		}
		close $in;
	}
	#die;
	print "Comparing files: @file\n";
	$total_id = keys %id;
	my $count_unique_id_less_than = 0;
	foreach my $id (sort keys %id) {
		my $identical = 0;
		my ($chr, $start, $mapq, $strand);
		my @exists_prog;

		foreach my $prog (sort @prog) {
			if (not defined($chr)) {
				next if not defined($read{$id}{$prog}{chr});
				$chr    = $read{$id}{$prog}{chr};
				$start  = $read{$id}{$prog}{start};
				$mapq   = $read{$id}{$prog}{mapq};
				$strand = $read{$id}{$prog}{strand};
				push(@exists_prog, $prog);
			}
			else {
				next if not defined($read{$id}{$prog}{chr});
				last if $identical == 1;
				$identical = 1 if $chr ne $read{$id}{$prog}{chr};
				$identical = 1 if $start ne $read{$id}{$prog}{start};
				$identical = 1 if $mapq ne $read{$id}{$prog}{mapq};
				$identical = 1 if $strand ne $read{$id}{$prog}{strand};
				push(@exists_prog, $prog);
			}
		}
		if ($identical == 0) {
			$count_unique_id ++ if @exists_prog == @prog;
			$count_unique_id_less_than ++ if @exists_prog < @prog;
			#my $prog = $exists_prog[0];
			#my $join_prog = join("_", @exists_prog);
			#my $line = $read{$id}{$prog}{line};
			#my ($names, @all) = split("\t", $line);
			#$line =~ s/$names/$names\_$join_prog/;
			#print $out "$line\n";
		}
		delete($read{$id});

	}
	print "$name\tunique id: $count_unique_id\tunique id less than 4: $count_unique_id_less_than\ttotal id: $total_id\n";
	#close $out;
	exit;
}
