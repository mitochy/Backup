#!/usr/bin/perl

use strict; use warnings;

my ($wig1, $wig2) = @ARGV;
die "Usage: $0 <wig 1> <wig 2>\n" unless @ARGV == 2;

my @chr;
my @grep1 = `grep chrom $wig1`;
my @grep2 = `grep chrom $wig2`;
foreach my $line (@grep1) {
	chomp($line);
	my ($chr) = $line =~ /chrom=(.+) span/;
	die "Died at $line\n" unless defined($chr);
	push(@chr, $chr) if not grep(/^$chr$/, @chr);
}
foreach my $line (@grep2) {
	chomp($line);
	my ($chr) = $line =~ /chrom=(.+) span/;
	die "Died at $line\n" unless defined($chr);
	push(@chr, $chr) if not grep(/^$chr$/, @chr);
}

my %count;
my %total;
for (my $i = 0; $i < @chr; $i++) {
	my %data;
	my $has_been_checked = 0;
	my $check_chr = $chr[$i];
	my $curr_chr = "INIT";
	open (my $in1, "<", $wig1) or die "Cannot read from $wig1: $!\n";
	while (my $line = <$in1>) {
		chomp($line);
		if ($line =~ /Step/i) {
			last if $has_been_checked == 1;
			my ($chr) = $line =~ /chrom=(.+) span/;
			$curr_chr = $chr;
		}
		elsif ($curr_chr eq $check_chr) {
			my ($pos, $val) = split("\t", $line);
			$data{$pos}{$wig1} = $val;
			$has_been_checked = 1;
		}
		elsif ($curr_chr ne $check_chr) {
			last if $has_been_checked == 1;
		}
	}
	close $in1;
	$has_been_checked = 0;
	$curr_chr = "INIT";
	open (my $in2, "<", $wig2) or die "Cannot read from $wig2: $!\n";
	while (my $line = <$in2>) {
		chomp($line);
		if ($line =~ /Step/i) {
			last if $has_been_checked == 1;
			my ($chr) = $line =~ /chrom=(.+) span/;
			$curr_chr = $chr;
		}
		elsif ($curr_chr eq $check_chr) {
			my ($pos, $val) = split("\t", $line);
			$data{$pos}{$wig2} = $val;
			$has_been_checked = 1;
		}
		elsif ($curr_chr ne $check_chr) {
			last if $has_been_checked == 1;
		}
	}
	close $in2;
	foreach my $pos (sort {$a <=> $b} keys %data) {
		$count{total} = 0 if not defined($count{total});
		$count{none}{wig1} = 0 if not defined($count{none}{wig1});
		$count{none}{wig2} = 0 if not defined($count{none}{wig2});
		$count{none}{both} = 0 if not defined($count{none}{both});
		$count{diff} = 0 if not defined($count{diff});
		$count{same} = 0 if not defined($count{same});
		$count{total}++;
		if (defined($data{$pos}{$wig1}) and defined($data{$pos}{$wig2})) {
			if ($data{$pos}{$wig1} =~ /\d+/ and $data{$pos}{$wig2} =~ /\d+/) {
				$count{diff}++ and next if ($data{$pos}{$wig1} != $data{$pos}{$wig2});
				$count{same}++ and next if ($data{$pos}{$wig1} == $data{$pos}{$wig2});
			}
			else {
				$count{none}{wig1}++ if $data{$pos}{$wig1} !~ /\d+/;
				$count{none}{wig2}++ if $data{$pos}{$wig2} !~ /\d+/;
				$count{none}{both}++;
				next;
			}
		}
		else {
			$count{none}{wig1}++ if not defined($data{$pos}{$wig1});
			$count{none}{wig2}++ if not defined($data{$pos}{$wig2});
			$count{none}{both}++;
			next;
		}
	}
	my $none = $count{none}{both} / $count{total} * 100;
	my $diff = $count{diff} / $count{total} * 100;
	my $same = $count{same} / $count{total} * 100;
	$total{total} += $count{total};
	$total{diff} += $count{diff};
	$total{same} += $count{same};
	$total{none} += $count{none}{both};
	my $wig1_none = $count{none}{wig1} / $count{total} * 100;
	my $wig2_none = $count{none}{wig2} / $count{total} * 100;
	print "Chr $check_chr:\n";
	print "\ttotal = $count{total}\n";
	print "\tnone  = $none % ($wig1 = $wig1_none, $wig2 = $wig2_none)\n";
	print "\tdiff  = $diff %\n";
	print "\tsame  = $same %\n";
	%count = ();
}

print "Total:\n";
my $none = $total{none} / $total{total} * 100;
my $diff = $total{diff} / $total{total} * 100;
my $same = $total{same} / $total{total} * 100;
print "\ttotal = $total{total}\n";
print "\tnone  = $none %\n";
print "\tdiff  = $diff %\n";
print "\tsame  = $same %\n";

